//
//  ArchetypeWorldSpawnTests.swift
//
//
//  Created by rrbox on 2026/07/07.
//

@testable import ECS
import Testing

/// World 分岐点 2 (`push`) / 3 (`despawn`) の archetype storage ON 経路のテストです。
///
/// applyCommandsPhase の結線(タスク4.3)前のため、`push` / `despawn` を直接呼び、
/// staging の適用は `applySpawnStaging()` を手動実行して検証します。
struct ArchetypeWorldSpawnTests {

    struct ComponentA: Component, Equatable {
        let value: Int
    }

    /// 旧 spawn 経路(`Commands.spawn`)と同じ手順で staging record を組み立てます。
    private func makeRecord(entity: Entity, value: Int? = nil) -> EntityRecordRef {
        let record = EntityRecordRef(entity: entity)
        record.map.body[ObjectIdentifier(Entity.self)] = ImmutableRef(value: entity)
        if let value {
            record.addComponent(ComponentA(value: value))
        }
        return record
    }

    /// entity を push し, staging を手動適用した ON の World を組み立てます。
    private func makeAppliedWorld(values: [Int]) throws -> (World, ArchetypeStorageRef, [Entity]) {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let entities = values.indices.map { Entity(slot: $0, generation: 0) }
        for (entity, value) in zip(entities, values) {
            world.push(entityRecord: self.makeRecord(entity: entity, value: value))
        }
        storage.applySpawnStaging()
        return (world, storage, entities)
    }

    private func columnA(of archetype: Archetype, storage: ArchetypeStorageRef) throws -> Column<ComponentA> {
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        return try #require(archetype.column(of: idA) as? Column<ComponentA>)
    }

    // MARK: - push (分岐点 2)

    /// ON: push は staging queue へ積むのみで、Archetype への挿入や旧 chunk queue への
    /// 追加は行われないことを確認します(挿入はタスク4.3 の applyCommandsPhase)。
    @Test func pushOnArchetypeWorldStagesRecordWithoutInsertion() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let entity = Entity(slot: 0, generation: 0)
        let record = self.makeRecord(entity: entity, value: 1)

        world.push(entityRecord: record)

        // staging queue に積まれるのみで、Archetype への挿入はまだ行われません。
        #expect(storage.spawnStagingQueue.count == 1)
        #expect(storage.spawnStagingQueue.first === record)
        #expect(storage.archetypes.isEmpty)
        #expect(storage.location(of: entity) == nil)

        // 旧経路の chunk queue は使用されません。
        let interface = try #require(
            world.worldStorage.chunkStorageRef.storage.valueRef(ofType: ChunkEntityInterface.self)?.body
        )
        #expect(interface.prespawnedEntityQueue.isEmpty)

        // World の entity table への登録は共通処理として維持されます。
        #expect(world.entityRecord(forEntity: entity) === record)
    }

    /// ON: `Spawned` イベントの発行が共通処理として維持されることを確認します(要件 1-6)。
    @Test func pushOnArchetypeWorldStillEmitsSpawnedEvent() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let entity = Entity(slot: 0, generation: 0)

        world.push(entityRecord: self.makeRecord(entity: entity))

        let queue = try #require(world.worldStorage.eventStorage.eventQueue(typeOf: Spawned.self))
        #expect(queue.eventWritingBuffer.map { $0.spawnedEntity } == [entity])
    }

    /// OFF: 従来どおり chunk queue に積まれ、archetype storage は存在しないことを確認します。
    @Test func pushOnDefaultWorldUsesChunkQueue() throws {
        let world = World()
        let entity = Entity(slot: 0, generation: 0)
        let record = self.makeRecord(entity: entity, value: 1)

        world.push(entityRecord: record)

        #expect(world.worldStorage.archetypeStorageRef == nil)
        let interface = try #require(
            world.worldStorage.chunkStorageRef.storage.valueRef(ofType: ChunkEntityInterface.self)?.body
        )
        #expect(interface.prespawnedEntityQueue.count == 1)
        #expect(interface.prespawnedEntityQueue.first === record)
    }

    // MARK: - despawn (分岐点 3)

    /// ON: 中間行の despawn で swap-remove が行われ、埋めた entity(filler)の
    /// 行番号が補正されることを確認します。
    @Test func despawnMiddleEntityCompactsRowsAndFixesFillerLocation() throws {
        let (world, storage, entities) = try self.makeAppliedWorld(values: [10, 20, 30])
        let archetype = try #require(storage.location(of: entities[1])).archetype

        world.despawn(entity: entities[1])

        // despawn した entity は所在・entity table の両方から消えます。
        #expect(storage.location(of: entities[1]) == nil)
        #expect(world.entityRecord(forEntity: entities[1]) == nil)

        // 末尾の entity が row 1 を埋め、所在が補正されます。
        #expect(archetype.entities == [entities[0], entities[2]])
        let fillerLocation = try #require(storage.location(of: entities[2]))
        #expect(fillerLocation.archetype === archetype)
        #expect(fillerLocation.row == 1)
        let location0 = try #require(storage.location(of: entities[0]))
        #expect(location0.row == 0)

        // カラムのデータも同期して詰められます。
        let column = try self.columnA(of: archetype, storage: storage)
        #expect(column.data == [ComponentA(value: 10), ComponentA(value: 30)])
    }

    /// ON: 末尾行の despawn(filler なし)が正しく処理されることを確認します。
    @Test func despawnLastEntityRemovesRowWithoutFiller() throws {
        let (world, storage, entities) = try self.makeAppliedWorld(values: [10, 20])
        let archetype = try #require(storage.location(of: entities[1])).archetype

        world.despawn(entity: entities[1])

        #expect(storage.location(of: entities[1]) == nil)
        #expect(archetype.entities == [entities[0]])
        let location0 = try #require(storage.location(of: entities[0]))
        #expect(location0.row == 0)
        let column = try self.columnA(of: archetype, storage: storage)
        #expect(column.data == [ComponentA(value: 10)])
    }

    /// ON: 唯一の行の despawn で Archetype が空になることを確認します。
    @Test func despawnOnlyEntityLeavesEmptyArchetype() throws {
        let (world, storage, entities) = try self.makeAppliedWorld(values: [10])
        let archetype = try #require(storage.location(of: entities[0])).archetype

        world.despawn(entity: entities[0])

        #expect(storage.location(of: entities[0]) == nil)
        #expect(archetype.entities.isEmpty)
        let column = try self.columnA(of: archetype, storage: storage)
        #expect(column.data.isEmpty)
    }

    /// ON: 未登録 entity の despawn が安全な no-op であることを確認します。
    @Test func despawnUnknownEntityIsSafeNoOp() throws {
        let (world, storage, entities) = try self.makeAppliedWorld(values: [10])

        // slot が sparse の範囲外の entity。
        world.despawn(entity: Entity(slot: 5, generation: 0))

        let location0 = try #require(storage.location(of: entities[0]))
        #expect(location0.row == 0)
        #expect(location0.archetype.entities == [entities[0]])
    }

    /// ON: 同一 entity の二重 despawn が安全な no-op であることを確認します。
    @Test func despawnTwiceIsSafeNoOp() throws {
        let (world, storage, entities) = try self.makeAppliedWorld(values: [10, 20])
        let archetype = try #require(storage.location(of: entities[0])).archetype

        world.despawn(entity: entities[0])
        world.despawn(entity: entities[0])

        #expect(storage.location(of: entities[0]) == nil)
        #expect(archetype.entities == [entities[1]])
        let location1 = try #require(storage.location(of: entities[1]))
        #expect(location1.row == 0)
    }

    /// ON: 世代不一致の entity への despawn が entityIndex を破壊しないことを確認します。
    ///
    /// World の entity table を経由すると別のバリデーションで停止するため、
    /// entityIndex に stale な世代が残るケースをストレージ直接登録で構成します。
    @Test func despawnStaleGenerationEntityIsSafeNoOp() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let entity = Entity(slot: 0, generation: 0)
        storage.insert(record: self.makeRecord(entity: entity, value: 10))

        // 同一 slot・別世代の entity に対する despawn は無視されます。
        world.despawn(entity: Entity(slot: 0, generation: 1))

        let location = try #require(storage.location(of: entity))
        #expect(location.row == 0)
        #expect(location.archetype.entities == [entity])
    }

    /// ON: Removed lifecycle への `pushDespawned` が共通処理として維持されることを
    /// 確認します(要件 1-7)。
    @Test func despawnOnArchetypeWorldStillPushesToRemovedLifecycle() throws {
        let (world, _, entities) = try self.makeAppliedWorld(values: [10])
        let receiver = try #require(world.worldStorage.eventStorage.removedEventReceiver())

        world.despawn(entity: entities[0])

        #expect(receiver.count == 1)
    }
}
