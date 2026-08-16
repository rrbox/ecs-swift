//
//  ArchetypeStorageTests.swift
//
//
//  Created by rrbox on 2026/07/07.
//

@testable import ECS
import Testing

struct ArchetypeStorageTests {

    struct ComponentA: Component, Equatable {
        let value: Int
    }

    struct ComponentB: Component, Equatable {
        let name: String
    }

    /// 通知された Archetype と storage を記録するテスト用オブザーバです。
    final class RecordingObserver: ArchetypeObserver {
        var createdArchetypes = [Archetype]()
        var notifiedStorages = [ArchetypeStorageRef]()

        func archetypeCreated(_ archetype: Archetype, storage: ArchetypeStorageRef) {
            self.createdArchetypes.append(archetype)
            self.notifiedStorages.append(storage)
        }
    }

    // MARK: - typeID

    @Test func typeIDReturnsSameIDForSameKey() {
        let storage = ArchetypeStorageRef()

        let idA0 = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let idB = storage.typeID(for: ObjectIdentifier(ComponentB.self))
        let idA1 = storage.typeID(for: ObjectIdentifier(ComponentA.self))

        #expect(idA0 == idA1)
        #expect(idA0 != idB)
    }

    // MARK: - findOrCreate

    @Test func findOrCreateReturnsSameInstanceForSameKeyEvenFromDifferentIDOrder() {
        let storage = ArchetypeStorageRef()
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let idB = storage.typeID(for: ObjectIdentifier(ComponentB.self))

        let first = storage.findOrCreate(
            key: ArchetypeKey(sorting: [idA, idB]),
            prototypes: [Column<ComponentA>(), Column<ComponentB>()]
        )
        let unusedPrototypes: [AnyColumn] = [Column<ComponentA>(), Column<ComponentB>()]
        let second = storage.findOrCreate(
            key: ArchetypeKey(sorting: [idB, idA]),
            prototypes: unusedPrototypes
        )

        #expect(first === second)
        #expect(storage.archetypes.count == 1)
        // 既存 Archetype に 2 回目の prototypes が与えられていない
        #expect(!second.columns.contains { column in
            unusedPrototypes.contains { $0 === column }
        })
    }

    @Test func findOrCreateCreatesNewArchetypeForDifferentKey() {
        let storage = ArchetypeStorageRef()
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let idB = storage.typeID(for: ObjectIdentifier(ComponentB.self))
        let keyAB = ArchetypeKey(sorting: [idA, idB])
        let keyA = ArchetypeKey(sorting: [idA])

        let archetypeAB = storage.findOrCreate(
            key: keyAB,
            prototypes: [Column<ComponentA>(), Column<ComponentB>()]
        )
        let archetypeA = storage.findOrCreate(
            key: keyA,
            prototypes: [Column<ComponentA>()]
        )

        #expect(archetypeAB !== archetypeA)
        #expect(storage.archetypes.count == 2)
        #expect(storage.byKey[keyAB] === archetypeAB)
        #expect(storage.byKey[keyA] === archetypeA)
    }

    // MARK: - Observer

    @Test func observerIsNotifiedOncePerCreationAndNotOnReuse() {
        let storage = ArchetypeStorageRef()
        let observer = RecordingObserver()
        storage.observers.append(observer)
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let keyA = ArchetypeKey(sorting: [idA])

        let created = storage.findOrCreate(key: keyA, prototypes: [Column<ComponentA>()])
        let reused = storage.findOrCreate(key: keyA, prototypes: [Column<ComponentA>()])

        #expect(reused === created)
        #expect(observer.createdArchetypes.count == 1)
        #expect(observer.createdArchetypes.first === created)
        #expect(observer.notifiedStorages.first === storage)
    }

    @Test func everyObserverIsNotifiedForEachCreation() {
        let storage = ArchetypeStorageRef()
        let observer0 = RecordingObserver()
        let observer1 = RecordingObserver()
        storage.observers.append(observer0)
        storage.observers.append(observer1)
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let idB = storage.typeID(for: ObjectIdentifier(ComponentB.self))

        let archetypeA = storage.findOrCreate(
            key: ArchetypeKey(sorting: [idA]),
            prototypes: [Column<ComponentA>()]
        )
        let archetypeAB = storage.findOrCreate(
            key: ArchetypeKey(sorting: [idA, idB]),
            prototypes: [Column<ComponentA>(), Column<ComponentB>()]
        )

        for observer in [observer0, observer1] {
            #expect(observer.createdArchetypes.count == 2)
            #expect(observer.createdArchetypes.first === archetypeA)
            #expect(observer.createdArchetypes.last === archetypeAB)
        }
    }

    // MARK: - entityIndex

    @Test func locationReturnsRegisteredLocationAndNilAfterRemoval() throws {
        let storage = ArchetypeStorageRef()
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let archetype = storage.findOrCreate(
            key: ArchetypeKey(sorting: [idA]),
            prototypes: [Column<ComponentA>()]
        )
        let entity = Entity(slot: 0, generation: 0)

        storage.setLocation(EntityLocation(archetype: archetype, row: 3), forEntity: entity)

        let location = try #require(storage.location(of: entity))
        #expect(location.archetype === archetype)
        #expect(location.row == 3)

        storage.removeLocation(of: entity)
        #expect(storage.location(of: entity) == nil)
    }

    @Test func locationReturnsNilForUnregisteredEntity() {
        let storage = ArchetypeStorageRef()

        // sparse が一度も伸びていないスロットでもクラッシュせず nil を返す
        #expect(storage.location(of: Entity(slot: 99, generation: 0)) == nil)
    }

    // MARK: - Generation check(要件 1-4)

    @Test func locationReturnsNilForNewerGenerationQuery() throws {
        let storage = ArchetypeStorageRef()
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let archetype = storage.findOrCreate(
            key: ArchetypeKey(sorting: [idA]),
            prototypes: [Column<ComponentA>()]
        )
        let registered = Entity(slot: 0, generation: 0)

        storage.setLocation(EntityLocation(archetype: archetype, row: 0), forEntity: registered)

        // 登録済み世代では取得できる
        _ = try #require(storage.location(of: registered))
        // 同一スロットの新しい世代では取得できない
        #expect(storage.location(of: Entity(slot: 0, generation: 1)) == nil)
    }

    @Test func locationReturnsNilForStaleGenerationAfterSlotReuse() throws {
        let storage = ArchetypeStorageRef()
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let archetype = storage.findOrCreate(
            key: ArchetypeKey(sorting: [idA]),
            prototypes: [Column<ComponentA>()]
        )
        let staleEntity = Entity(slot: 0, generation: 0)
        let reusedEntity = Entity(slot: 0, generation: 1)

        // generation 0 の spawn で sparse を伸ばし、despawn 後にスロットを再利用する
        storage.setLocation(EntityLocation(archetype: archetype, row: 0), forEntity: staleEntity)
        storage.removeLocation(of: staleEntity)
        storage.setLocation(EntityLocation(archetype: archetype, row: 5), forEntity: reusedEntity)

        // 古い世代の entity では取得できない
        #expect(storage.location(of: staleEntity) == nil)
        // 再利用後の世代では取得できる
        let location = try #require(storage.location(of: reusedEntity))
        #expect(location.row == 5)
    }

    @Test func removeLocationIgnoresMismatchedGeneration() throws {
        let storage = ArchetypeStorageRef()
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let archetype = storage.findOrCreate(
            key: ArchetypeKey(sorting: [idA]),
            prototypes: [Column<ComponentA>()]
        )
        let registered = Entity(slot: 0, generation: 0)

        storage.setLocation(EntityLocation(archetype: archetype, row: 0), forEntity: registered)
        // 世代が一致しない削除要求は無視される
        storage.removeLocation(of: Entity(slot: 0, generation: 1))

        _ = try #require(storage.location(of: registered))
    }

}
