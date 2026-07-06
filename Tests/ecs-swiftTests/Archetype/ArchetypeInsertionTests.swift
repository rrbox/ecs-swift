//
//  ArchetypeInsertionTests.swift
//
//
//  Created by rrbox on 2026/07/07.
//

@testable import ECS
import Testing

struct ArchetypeInsertionTests {

    struct ComponentA: Component, Equatable {
        let value: Int
    }

    struct ComponentB: Component, Equatable {
        let name: String
    }

    /// 旧 spawn 経路(Commands.spawn)と同じ手順で staging record を組み立てます.
    private func makeRecord(entity: Entity) -> EntityRecordRef {
        let record = EntityRecordRef(entity: entity)
        record.map.body[ObjectIdentifier(Entity.self)] = ImmutableRef(value: entity)
        return record
    }

    // MARK: - insert(record:)

    @Test func insertSingleRecordRegistersLocationAndColumnData() throws {
        let storage = ArchetypeStorageRef()
        let entity = Entity(slot: 0, generation: 0)
        let record = self.makeRecord(entity: entity)
        record.addComponent(ComponentA(value: 42))
        record.addComponent(ComponentB(name: "a"))

        storage.insert(record: record)

        let location = try #require(storage.location(of: entity))
        let archetype = location.archetype
        #expect(location.row == 0)
        #expect(archetype.entities == [entity])

        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let idB = storage.typeID(for: ObjectIdentifier(ComponentB.self))
        #expect(archetype.key == ArchetypeKey(sorting: [idA, idB]))

        let columnA = try #require(archetype.column(of: idA) as? Column<ComponentA>)
        let columnB = try #require(archetype.column(of: idB) as? Column<ComponentB>)
        #expect(columnA.data == [ComponentA(value: 42)])
        #expect(columnB.data == [ComponentB(name: "a")])
    }

    @Test func insertTwoRecordsWithDifferentComponentOrderShareArchetype() throws {
        let storage = ArchetypeStorageRef()
        let entity0 = Entity(slot: 0, generation: 0)
        let entity1 = Entity(slot: 1, generation: 0)

        // 同じ型集合を, addComponent の順序を変えて登録します.
        let record0 = self.makeRecord(entity: entity0)
        record0.addComponent(ComponentA(value: 1))
        record0.addComponent(ComponentB(name: "first"))
        let record1 = self.makeRecord(entity: entity1)
        record1.addComponent(ComponentB(name: "second"))
        record1.addComponent(ComponentA(value: 2))

        storage.insert(record: record0)
        storage.insert(record: record1)

        let location0 = try #require(storage.location(of: entity0))
        let location1 = try #require(storage.location(of: entity1))

        // 挿入順序が異なっても同一の Archetype インスタンスに合流します.
        #expect(location0.archetype === location1.archetype)
        #expect(storage.archetypes.count == 1)

        let archetype = location0.archetype
        #expect(archetype.entities.count == 2)
        #expect(location0.row == 0)
        #expect(location1.row == 1)

        // 各型のカラムに, 行番号どおりの値が格納されています.
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let idB = storage.typeID(for: ObjectIdentifier(ComponentB.self))
        let columnA = try #require(archetype.column(of: idA) as? Column<ComponentA>)
        let columnB = try #require(archetype.column(of: idB) as? Column<ComponentB>)
        #expect(columnA.data == [ComponentA(value: 1), ComponentA(value: 2)])
        #expect(columnB.data == [ComponentB(name: "first"), ComponentB(name: "second")])
    }

    @Test func insertRecordWithNoComponentsCreatesEmptyKeyArchetype() throws {
        let storage = ArchetypeStorageRef()
        let entity = Entity(slot: 0, generation: 0)
        let record = self.makeRecord(entity: entity)

        storage.insert(record: record)

        let location = try #require(storage.location(of: entity))
        // コンポーネント 0 個の entity は空キーの Archetype に所属します.
        #expect(location.archetype.key == ArchetypeKey(sorting: []))
        #expect(location.archetype.columns.isEmpty)
        #expect(location.archetype.entities == [entity])
        #expect(location.row == 0)
    }

    // MARK: - applySpawnStaging

    @Test func applySpawnStagingDrainsQueueAndInsertsAllRecords() throws {
        let storage = ArchetypeStorageRef()
        let entity0 = Entity(slot: 0, generation: 0)
        let entity1 = Entity(slot: 1, generation: 0)
        let record0 = self.makeRecord(entity: entity0)
        record0.addComponent(ComponentA(value: 10))
        let record1 = self.makeRecord(entity: entity1)
        record1.addComponent(ComponentA(value: 20))

        storage.spawnStagingQueue.append(record0)
        storage.spawnStagingQueue.append(record1)

        storage.applySpawnStaging()

        #expect(storage.spawnStagingQueue.isEmpty)
        let location0 = try #require(storage.location(of: entity0))
        let location1 = try #require(storage.location(of: entity1))
        #expect(location0.archetype === location1.archetype)

        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let columnA = try #require(location0.archetype.column(of: idA) as? Column<ComponentA>)
        #expect(columnA.data == [ComponentA(value: 10), ComponentA(value: 20)])
    }

    @Test func applySpawnStagingWithEmptyQueueDoesNothing() {
        let storage = ArchetypeStorageRef()

        storage.applySpawnStaging()

        #expect(storage.spawnStagingQueue.isEmpty)
        #expect(storage.archetypes.isEmpty)
    }
}
