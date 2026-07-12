//
//  ArchetypeQueryTests.swift
//
//
//  Created by rrbox on 2026/07/07.
//

@testable import ECS
import Testing

/// `Query<C>`(1型)デュアルバックエンドの archetype storage ON 経路のテストです(タスク 5.2)。
///
/// `world.update(currentTime:)` のフレームを実際に回し、system parameter として
/// 解決された `Query<C>` が Archetype バックエンドで動作することを検証します
/// (要件 2-1, 2-2, 2-4, 2-6, 2-7)。公開 API(`update` / `components(forEntity:)`)は
/// OFF 経路と同一です。
struct ArchetypeQueryTests {

    struct ComponentA: Component, Equatable {
        var value: Int
    }

    struct ComponentB: Component, Equatable {
        var text: String
    }

    // MARK: - 部分集合マッチ (要件 2-1, 2-2)

    /// ON: `Query<ComponentA>` が「A のみ」「A + B」両方の entity をイテレーションする
    /// ことを確認します(要求型集合 ⊆ archetype 型集合の部分集合マッチ)。
    @Test func queryIteratesEntitiesWithSubsetMatching() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        commands.spawn()
            .addComponent(ComponentA(value: 1))
        commands.spawn()
            .addComponent(ComponentA(value: 2))
            .addComponent(ComponentB(text: "x"))

        var observed = [Int]()
        world.addSystem(.update) { (query: Query<ComponentA>) in
            guard observed.isEmpty else { return }
            query.update { component in
                observed.append(component.value)
            }
        }

        // 最初のフレームは準備用フレームのため, .update システムは 2 フレーム目から実行されます.
        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        #expect(observed.sorted() == [1, 2])
    }

    // MARK: - 変更の永続化 (要件 2-4, 2-7)

    /// ON: `update(_:)` での変更が次フレームまで永続化され、`components(forEntity:)`
    /// からも見えることを確認します。
    @Test func mutationPersistsAcrossFramesAndIsVisibleViaComponentsForEntity() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 0))
            .id()

        var readBack = [Int?]()
        world.addSystem(.update) { (query: Query<ComponentA>) in
            readBack.append(query.components(forEntity: entity)?.value)
            query.update { component in
                component.value += 1
            }
        }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        // フレーム 1 で 0 を読み +1、フレーム 2 で永続化された 1 を読みます。
        #expect(readBack == [0, 1])
    }

    // MARK: - Entity ターゲット (要件 2-6)

    /// ON: `Query<Entity>` が(コンポーネントを持たない entity も含め)全 entity の
    /// ID をイテレーションすることを確認します。
    @Test func entityTargetQueryIteratesAllEntityIDs() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        let entityA = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        let entityB = commands.spawn()
            .addComponent(ComponentB(text: "x"))
            .id()
        let bareEntity = commands.spawn().id()

        var observed = Set<Entity>()
        world.addSystem(.update) { (query: Query<Entity>) in
            query.update { entity in
                observed.insert(entity)
            }
        }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        #expect(observed == [entityA, entityB, bareEntity])
    }

    // MARK: - entity 指定アクセス (要件 2-7)

    /// ON: `update(_:_:)` による対象 entity のみの読み書きが動作し、他の entity に
    /// 影響しないことを確認します。
    @Test func targetedUpdateReadsAndWritesSingleEntity() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        let target = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        let other = commands.spawn()
            .addComponent(ComponentA(value: 2))
            .id()

        var didWrite = false
        var results: [Int?]?
        world.addSystem(.update) { (query: Query<ComponentA>) in
            if !didWrite {
                didWrite = true
                query.update(target) { component in
                    component.value = 10
                }
            } else if results == nil {
                results = [
                    query.components(forEntity: target)?.value,
                    query.components(forEntity: other)?.value,
                ]
            }
        }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        #expect(results == [10, 2])
    }

    // MARK: - register 後に生成された Archetype の観測 (observer 経路)

    /// ON: Query の register 時点で Archetype が存在せず、後続フレーム中の spawn で
    /// 生成された Archetype がオブザーバ通知経由でマッチに追加されることを確認します。
    @Test func archetypeCreatedAfterRegisterIsObserved() throws {
        let world = World(experimentalOptions: [.archetypeStorage])

        var spawned = false
        var perFrame = [[Int]]()
        world
            .addSystem(.update) { (commands: Commands) in
                guard !spawned else { return }
                spawned = true
                commands.spawn()
                    .addComponent(ComponentA(value: 5))
            }
            .addSystem(.update) { (query: Query<ComponentA>) in
                var values = [Int]()
                query.update { component in
                    values.append(component.value)
                }
                perFrame.append(values)
            }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        // フレーム 1 では spawn は遅延適用のため空、フレーム 2 で見えます。
        #expect(perFrame == [[], [5]])
    }

    // MARK: - 既存 Archetype への遡及マッチ (retro-match 経路)

    /// ON: Query の register より前に生成済みの Archetype が、register 時の
    /// 遡及マッチで `archetypeMatches` に追加されることを確認します
    /// (addSystem を最初のフレーム後に呼ぶことで register を遅らせます)。
    @Test func registerRetroactivelyMatchesExistingArchetypes() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        commands.spawn()
            .addComponent(ComponentA(value: 3))

        // Query 未登録のままフレームを回し、Archetype を先に生成します。
        world.setUpWorld()
        world.update(currentTime: 0)

        var observed = [Int]()
        world.addSystem(.update) { (query: Query<ComponentA>) in
            guard observed.isEmpty else { return }
            query.update { component in
                observed.append(component.value)
            }
        }

        // register 時の遡及マッチで既存 Archetype が見えています。
        let query = try #require(Query<ComponentA>.getParameter(from: world.worldStorage))
        #expect(query.archetypeMatches.count == 1)

        world.update(currentTime: 1)

        #expect(observed == [3])
    }

    // MARK: - despawn の反映 (要件 1-2 の Query ビュー)

    /// ON: despawn された entity が以降のイテレーションと `components(forEntity:)` から
    /// 除外されることを確認します。
    @Test func despawnedEntityIsNoLongerIterated() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()

        var perFrame = [[Int]]()
        world.addSystem(.update) { (query: Query<ComponentA>) in
            var values = [Int]()
            query.update { component in
                values.append(component.value)
            }
            perFrame.append(values)
        }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        commands.despawn(entity: entity)
        world.update(currentTime: 2)

        #expect(perFrame == [[1], []])

        let query = try #require(Query<ComponentA>.getParameter(from: world.worldStorage))
        #expect(query.components(forEntity: entity) == nil)
    }

    // MARK: - OFF 経路の維持 (要件 4-1)

    /// OFF: 従来の Query の挙動(イテレーション・変更の永続化・entity 指定取得)が
    /// 影響を受けないことを確認します(完全な保証は既存テストスイート全体の通過によります)。
    @Test func offWorldQueryKeepsCurrentBehavior() throws {
        let world = World()
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()

        var readBack = [Int?]()
        world.addSystem(.update) { (query: Query<ComponentA>) in
            readBack.append(query.components(forEntity: entity)?.value)
            query.update { component in
                component.value += 1
            }
        }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        #expect(readBack == [1, 2])
    }

    // MARK: - 新旧パラメタライズ統合テスト (タスク 7.1)

    /// 両バックエンド: 要求型集合の部分集合マッチが一致します(要件 2-1, 2-2)。
    /// `Query<A>` は「A のみ」「A + B」の両方を、`Query2<A, B>` は「A + B」のみを対象とします。
    @Test(arguments: WorldBackend.allCases)
    func queryMembershipMatchesRequiredTypeSet(backend: WorldBackend) {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        commands.spawn()
            .addComponent(ComponentA(value: 1))
        commands.spawn()
            .addComponent(ComponentA(value: 2))
            .addComponent(ComponentB(text: "both"))
        commands.spawn()
            .addComponent(ComponentB(text: "onlyB"))

        var observedA = [Int]()
        var observedAB = [Int]()
        world
            .addSystem(.update) { (query: Query<ComponentA>) in
                guard observedA.isEmpty else { return }
                query.update { component in
                    observedA.append(component.value)
                }
            }
            .addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
                guard observedAB.isEmpty else { return }
                query.update { a, _ in
                    observedAB.append(a.value)
                }
            }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        #expect(observedA.sorted() == [1, 2])
        #expect(observedAB == [2])
    }

    /// 両バックエンド: 型パラメータの記述順が異なる `Query2<A, B>` / `Query2<B, A>` が
    /// 同一の entity 集合を対象とします(要件 2-3)。
    @Test(arguments: WorldBackend.allCases)
    func typeOrderDoesNotChangeMatchedEntitySet(backend: WorldBackend) {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        commands.spawn()
            .addComponent(ComponentA(value: 1))
            .addComponent(ComponentB(text: "p"))
        commands.spawn()
            .addComponent(ComponentA(value: 2))
            .addComponent(ComponentB(text: "q"))
        commands.spawn()
            .addComponent(ComponentA(value: 3))

        var observedAB = Set<Int>()
        var observedBA = Set<Int>()
        world
            .addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
                query.update { a, _ in
                    observedAB.insert(a.value)
                }
            }
            .addSystem(.update) { (query: Query2<ComponentB, ComponentA>) in
                query.update { _, a in
                    observedBA.insert(a.value)
                }
            }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        #expect(observedAB == [1, 2])
        #expect(observedBA == observedAB)
    }

    /// 両バックエンド: `update(_:)` での変更が同一フレーム内の別 Query と
    /// `components(forEntity:)` の両方から見えます(要件 2-4)。
    @Test(arguments: WorldBackend.allCases)
    func mutationIsVisibleToOtherQueryAndComponentsForEntity(backend: WorldBackend) throws {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .addComponent(ComponentB(text: "b"))
            .id()

        var observedByOtherQuery = [Int]()
        world
            .addSystem(.update) { (query: Query<ComponentA>) in
                query.update { component in
                    component.value += 10
                }
            }
            .addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
                query.update { a, _ in
                    observedByOtherQuery.append(a.value)
                }
            }

        world.setUpWorld()
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        // 先行システムの変更が同一フレームの後続システム(別 Query)から見えます。
        #expect(observedByOtherQuery == [11])

        // `components(forEntity:)` からも変更後の値が見えます。
        let query = try #require(Query<ComponentA>.getParameter(from: world.worldStorage))
        #expect(query.components(forEntity: entity) == ComponentA(value: 11))
    }

    /// 両バックエンド: `update(_:_:)` は対象 entity のみを更新し、対象型を持たない
    /// entity への `components(forEntity:)` / `update(_:_:)` は何も返しません
    /// (要件 2-7 の両バックエンド回帰)。
    @Test(arguments: WorldBackend.allCases)
    func targetedUpdateAndComponentsForEntityNonMatch(backend: WorldBackend) throws {
        let world = backend.makeWorld()
        let commands = world.worldStorage.commands

        let target = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        let other = commands.spawn()
            .addComponent(ComponentA(value: 2))
            .id()
        let onlyB = commands.spawn()
            .addComponent(ComponentB(text: "b"))
            .id()

        // Query を register するためのシステムです(内容は使いません)。
        world.addSystem(.update) { (_: Query<ComponentA>) in }
        world.setUpWorld()
        world.update(currentTime: 0)

        let query = try #require(Query<ComponentA>.getParameter(from: world.worldStorage))

        // 対象 entity のみが更新され、他の entity は影響を受けません。
        query.update(target) { component in
            component.value = 10
        }
        #expect(query.components(forEntity: target) == ComponentA(value: 10))
        #expect(query.components(forEntity: other) == ComponentA(value: 2))

        // 対象型を持たない entity は nil / no-op です。
        #expect(query.components(forEntity: onlyB) == nil)
        var nonMatchTouched = false
        query.update(onlyB) { _ in
            nonMatchTouched = true
        }
        #expect(!nonMatchTouched)
    }
}
