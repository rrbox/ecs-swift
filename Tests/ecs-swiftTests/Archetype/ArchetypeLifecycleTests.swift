//
//  ArchetypeLifecycleTests.swift
//
//
//  Created by rrbox on 2026/07/09.
//

@testable import ECS
import Testing

/// entity のライフサイクル(spawn / despawn / 構成変更 / slot 再利用 / イベント)を
/// 新旧両バックエンドで検証する統合テストです(タスク 7.1)。
///
/// 全テストは `@Test(arguments: WorldBackend.allCases)` により legacy / archetype の
/// 両方の World で実行され、公開 API レベルで同一の挙動になることを確認します
/// (要件 1-1, 1-2, 1-3, 1-4, 1-6, 1-7)。
struct ArchetypeLifecycleTests {

    struct ComponentA: Component, Equatable {
        var value: Int
    }

    struct ComponentB: Component, Equatable {
        var text: String
    }

    // MARK: - spawn の反映 (要件 1-1)

    /// spawn したフレームの適用フェーズが完了した後、entity が(指定型以外の
    /// コンポーネントを追加で持っていても)一致する Query の対象に含まれます。
    /// spawn 発行フレーム内では未反映(遅延適用)であることも確認します。
    @Test(arguments: WorldBackend.allCases)
    func spawnedEntityEntersMatchingQueriesAfterApply(backend: WorldBackend) {
        let world = backend.makeWorld()

        var spawned = false
        var perFrame = [[Int]]()
        world
            .addSystem(.update) { (commands: Commands) in
                guard !spawned else { return }
                spawned = true
                commands.spawn()
                    .addComponent(ComponentA(value: 1))
                commands.spawn()
                    .addComponent(ComponentA(value: 2))
                    .addComponent(ComponentB(text: "extra"))
            }
            .addSystem(.update) { (query: Query<ComponentA>) in
                var values = [Int]()
                query.update { component in
                    values.append(component.value)
                }
                perFrame.append(values.sorted())
            }

        // 最初のフレームは準備用フレームのため, .update システムは 2 フレーム目から実行されます.
        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        // spawn 発行フレームでは空、適用後の次フレームで両 entity が対象に入ります。
        #expect(perFrame == [[], [1, 2]])
    }

    // MARK: - despawn の除外 (要件 1-2)

    /// despawn したフレームの適用フェーズが完了した後、entity が Query の
    /// イテレーションと `components(forEntity:)` の両方から除外されます。
    @Test(arguments: WorldBackend.allCases)
    func despawnedEntityIsExcludedFromQueries(backend: WorldBackend) throws {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        let keep = commands.spawn()
            .addComponent(ComponentA(value: 2))
            .id()

        var perFrame = [[Int]]()
        world.addSystem(.update) { (query: Query<ComponentA>) in
            var values = [Int]()
            query.update { component in
                values.append(component.value)
            }
            perFrame.append(values.sorted())
        }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        commands.despawn(entity: entity)
        world.update(currentTime: 2)

        #expect(perFrame == [[1, 2], [2]])

        let query = try #require(Query<ComponentA>.getParameter(from: world.worldStorage))
        #expect(query.components(forEntity: entity) == nil)
        #expect(query.components(forEntity: keep) == ComponentA(value: 2))
    }

    // MARK: - 構成変更による Query 対象の出入り (要件 1-3)

    /// 既存 entity への `addComponent` の適用完了後、変更後の型集合に一致する
    /// Query の対象に entity が入ります。
    @Test(arguments: WorldBackend.allCases)
    func addComponentMovesEntityIntoQueryScope(backend: WorldBackend) {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()

        var perFrame = [[Int]]()
        world.addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
            var values = [Int]()
            query.update { a, _ in
                values.append(a.value)
            }
            perFrame.append(values)
        }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        commands.entity(entity).addComponent(ComponentB(text: "b"))
        world.update(currentTime: 2)

        // B 追加前は対象外、追加の適用後に対象へ入ります。
        #expect(perFrame == [[], [1]])
    }

    /// 既存 entity からの `removeComponent` の適用完了後、削除した型を要求する
    /// Query の対象から entity が外れます(残った型の Query には残ります)。
    @Test(arguments: WorldBackend.allCases)
    func removeComponentMovesEntityOutOfQueryScope(backend: WorldBackend) throws {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 7))
            .addComponent(ComponentB(text: "x"))
            .id()

        var perFrame = [[Int]]()
        world
            .addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
                var values = [Int]()
                query.update { a, _ in
                    values.append(a.value)
                }
                perFrame.append(values)
            }
            // 残存側の確認用に Query<ComponentA> を register しておきます。
            .addSystem(.update) { (_: Query<ComponentA>) in }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        commands.entity(entity).removeComponent(ofType: ComponentB.self)
        world.update(currentTime: 2)

        #expect(perFrame == [[7], []])

        // 残った A のみを要求する Query には引き続き含まれます。
        let queryA = try #require(Query<ComponentA>.getParameter(from: world.worldStorage))
        #expect(queryA.components(forEntity: entity) == ComponentA(value: 7))
    }

    // MARK: - slot 再利用の世代分離 (要件 1-4)

    /// despawn された slot が新しい世代で再利用された場合、古い世代の entity としての
    /// アクセス(`components(forEntity:)` / `update(_:_:)`)はデータを返しません。
    @Test(arguments: WorldBackend.allCases)
    func slotReuseDoesNotExposeDataToOldGeneration(backend: WorldBackend) throws {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        // Query を register するためのシステムです(内容は使いません)。
        world.addSystem(.update) { (_: Query<ComponentA>) in }

        let old = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.setUpWorld()
        world.update(currentTime: 0)

        commands.despawn(entity: old)
        world.update(currentTime: 1)

        // despawn で stack された slot が新しい世代で再利用されます(EntityGenerator の規約)。
        let reused = commands.spawn()
            .addComponent(ComponentA(value: 2))
            .id()
        #expect(reused.slot == old.slot)
        #expect(reused.generation == old.generation + 1)

        world.update(currentTime: 2)

        let query = try #require(Query<ComponentA>.getParameter(from: world.worldStorage))
        #expect(query.components(forEntity: reused) == ComponentA(value: 2))

        // 古い世代としてのアクセスは読み取り・書き込みともに何も起こしません。
        #expect(query.components(forEntity: old) == nil)
        var oldGenerationTouched = false
        query.update(old) { _ in
            oldGenerationTouched = true
        }
        #expect(!oldGenerationTouched)
        #expect(query.components(forEntity: reused) == ComponentA(value: 2))
    }

    // MARK: - Spawned イベント (要件 1-6)

    /// spawn の適用時に `Spawned` イベントが発行され、次フレームの
    /// `EventReader<Spawned>` システムに配信されます。
    @Test(arguments: WorldBackend.allCases)
    func spawnApplyEmitsSpawnedEvent(backend: WorldBackend) {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        var received = [Entity]()
        world.addSystem(.update) { (events: EventReader<Spawned>) in
            events.forEach { event in
                received.append(event.spawnedEntity)
            }
        }

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        #expect(received == [entity])
    }

    // MARK: - Removed スケジュール (要件 1-7)

    /// despawn の適用時に `.removed` スケジュールのシステムが実行され、
    /// 削除された entity 一覧が渡されます。
    @Test(arguments: WorldBackend.allCases)
    func despawnApplyRunsRemovedScheduleWithEntities(backend: WorldBackend) {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        var received = [Entity]()
        world.addSystem(.removed) { (removed: Removed) in
            removed.forEach { removedEntity in
                received.append(removedEntity)
            }
        }

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.setUpWorld()
        world.update(currentTime: 0)

        commands.despawn(entity: entity)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        #expect(received == [entity])
    }
}
