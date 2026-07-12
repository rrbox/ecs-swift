//
//  ArchetypeCommandsPhaseTests.swift
//
//
//  Created by rrbox on 2026/07/07.
//

@testable import ECS
import Testing

/// World 分岐点 4 (`applyCommandsPhase`) の archetype storage ON 経路のテストです。
///
/// `world.update(currentTime:)` の 1 フレームを実際に回し、`Commands` 経由の
/// spawn / despawn がフレームの適用フェーズで Archetype ストレージへ反映されることを
/// 検証します(要件 1-1, 1-5, 3-1)。diff queue の適用はタスク 6.3 で結線されるため、
/// ここでは扱いません。
struct ArchetypeCommandsPhaseTests {

    struct ComponentA: Component, Equatable {
        let value: Int
    }

    struct ComponentB: Component, Equatable {
        let text: String
    }

    private func column<T: Component>(
        of type: T.Type,
        in archetype: Archetype,
        storage: ArchetypeStorageRef
    ) throws -> Column<T> {
        let id = storage.typeID(for: ObjectIdentifier(T.self))
        return try #require(archetype.column(of: id) as? Column<T>)
    }

    // MARK: - spawn の適用 (要件 1-1, 3-1)

    /// ON: `commands.spawn().addComponent(...)` がフレームの適用フェーズ後に
    /// Archetype へ挿入され、両コンポーネントの値が正しいことを確認します。
    /// spawn API は現行と同一です(要件 3-1)。
    @Test func spawnCommandInsertsEntityIntoArchetypeAfterApply() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .addComponent(ComponentB(text: "x"))
            .id()

        world.setUpWorld()
        world.update(currentTime: 0)

        // 適用後は entityIndex から所在を引けます。
        let location = try #require(storage.location(of: entity))
        #expect(location.archetype.entities[location.row] == entity)

        // spawn コマンドで追加した両コンポーネントの値が挿入されています。
        let columnA = try self.column(of: ComponentA.self, in: location.archetype, storage: storage)
        let columnB = try self.column(of: ComponentB.self, in: location.archetype, storage: storage)
        #expect(columnA.data[location.row] == ComponentA(value: 1))
        #expect(columnB.data[location.row] == ComponentB(text: "x"))

        // staging queue は適用後にクリアされます。
        #expect(storage.spawnStagingQueue.isEmpty)
    }

    // MARK: - 遅延適用 (要件 1-5)

    /// ON: フレーム N 中に spawn した entity は、同フレームの後続システムからは
    /// まだストレージ上に見えず(遅延適用)、フレームの適用フェーズ後に見えるように
    /// なることを確認します(Query は ON では未結線のため、ストレージ直接参照で
    /// 検証します)。
    @Test func spawnIsNotVisibleInStorageUntilApplyPhase() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)

        var spawnedEntity: Entity?
        var locationVisibleMidFrame: Bool?
        var stagingCountMidFrame: Int?

        world
            .addSystem(.update) { (commands: Commands) in
                guard spawnedEntity == nil else { return }
                spawnedEntity = commands.spawn()
                    .addComponent(ComponentA(value: 7))
                    .id()
            }
            .addSystem(.update) { (_: Commands) in
                guard let entity = spawnedEntity, locationVisibleMidFrame == nil else { return }
                locationVisibleMidFrame = storage.location(of: entity) != nil
                stagingCountMidFrame = storage.spawnStagingQueue.count
            }

        // 最初のフレームは準備用フレームのため, システムは 2 フレーム目から実行されます.
        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        let entity = try #require(spawnedEntity)

        // 同フレーム内の後続システムからはまだストレージに反映されていません。
        #expect(locationVisibleMidFrame == false)
        #expect(stagingCountMidFrame == 0)

        // フレームの適用フェーズ後は所在を引けます。
        let location = try #require(storage.location(of: entity))
        let columnA = try self.column(of: ComponentA.self, in: location.archetype, storage: storage)
        #expect(columnA.data[location.row] == ComponentA(value: 7))
    }

    // MARK: - despawn の適用 (要件 1-2, 1-5)

    /// ON: 後続フレームでの `commands.despawn(_)` が適用フェーズ後にストレージから
    /// entity を削除することを確認します。
    @Test func despawnCommandRemovesEntityFromStorageAfterApply() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.setUpWorld()
        world.update(currentTime: 0)
        let archetype = try #require(storage.location(of: entity)).archetype

        commands.despawn(entity: entity)
        world.update(currentTime: 1)

        // 所在・entity table・Archetype の行がすべて削除されています。
        #expect(storage.location(of: entity) == nil)
        #expect(world.entityRecord(forEntity: entity) == nil)
        #expect(archetype.entities.isEmpty)
        let columnA = try self.column(of: ComponentA.self, in: archetype, storage: storage)
        #expect(columnA.data.isEmpty)
    }

    // MARK: - Spawned イベント (要件 1-6)

    /// ON: spawn した entity の `Spawned` イベントが次フレームの `EventReader` システムに
    /// 配信されることを確認します(OFF 経路の既存セマンティクスと同一)。
    @Test func spawnedEventIsDeliveredToReaderSystemOnNextFrame() throws {
        var spawnedEntity: Entity?
        var received = [Entity]()

        let world = World(experimentalOptions: [.archetypeStorage])
            .addSystem(.startUp) { (commands: Commands) in
                spawnedEntity = commands.spawn()
                    .addComponent(ComponentA(value: 1))
                    .id()
            }
            .addSystem(.update) { (events: EventReader<Spawned>) in
                events.forEach { received.append($0.spawnedEntity) }
            }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        let entity = try #require(spawnedEntity)
        #expect(received == [entity])
    }

    // MARK: - OFF 経路の維持 (要件 4-1)

    /// OFF: 従来の spawn / despawn フローが影響を受けないことを確認します
    /// (完全な保証は既存テストスイート全体の通過によります)。
    @Test func offWorldSpawnAndDespawnKeepCurrentBehavior() throws {
        let world = World()
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.setUpWorld()
        world.update(currentTime: 0)

        let record = try #require(world.entityRecord(forEntity: entity))
        #expect(record.ref(ComponentA.self)?.value == ComponentA(value: 1))

        commands.despawn(entity: entity)
        world.update(currentTime: 1)

        #expect(world.entityRecord(forEntity: entity) == nil)
    }
}
