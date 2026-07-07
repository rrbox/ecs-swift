//
//  ArchetypeQueryNTests.swift
//
//
//  Created by rrbox on 2026/07/07.
//

@testable import ECS
import Testing

/// `QueryN`(マクロ生成、2〜10型)デュアルバックエンドの archetype storage ON 経路の
/// テストです(タスク 5.3)。
///
/// `world.update(currentTime:)` のフレームを実際に回し、system parameter として
/// 解決された `QueryN` が Archetype バックエンドで動作することを検証します
/// (要件 2-1〜2-4, 2-6, 2-7)。公開 API(`update` / `components(forEntity:)`)は
/// OFF 経路と同一です。
struct ArchetypeQueryNTests {

    struct ComponentA: Component, Equatable {
        var value: Int
    }

    struct ComponentB: Component, Equatable {
        var text: String
    }

    // MARK: - 部分集合マッチ (要件 2-1, 2-2)

    /// ON: `Query2<A, B>` が「A と B の両方を持つ」entity のみをイテレーションし、
    /// 値が正しく渡されることを確認します(A のみ・B のみの entity は除外されます)。
    @Test func query2IteratesOnlyEntitiesWithBothComponents() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        commands.spawn()
            .addComponent(ComponentA(value: 1))
        commands.spawn()
            .addComponent(ComponentB(text: "onlyB"))
        commands.spawn()
            .addComponent(ComponentA(value: 2))
            .addComponent(ComponentB(text: "both"))

        var observed = [(Int, String)]()
        world.addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
            guard observed.isEmpty else { return }
            query.update { a, b in
                observed.append((a.value, b.text))
            }
        }

        // 最初のフレームは準備用フレームのため, .update システムは 2 フレーム目から実行されます.
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        #expect(observed.count == 1)
        #expect(observed.first?.0 == 2)
        #expect(observed.first?.1 == "both")
    }

    // MARK: - 変更の永続化 (要件 2-4)

    /// ON: `update(_:)` での変更が次フレームまで永続化されることを確認します。
    @Test func query2MutationPersistsAcrossFrames() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        commands.spawn()
            .addComponent(ComponentA(value: 0))
            .addComponent(ComponentB(text: ""))

        var readBack = [[Int]]()
        world.addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
            var values = [Int]()
            query.update { a, b in
                values.append(a.value)
                a.value += 1
                b.text += "x"
            }
            readBack.append(values)
        }

        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        // フレーム 1 で 0 を読み +1、フレーム 2 で永続化された 1 を読みます。
        #expect(readBack == [[0], [1]])
    }

    // MARK: - 型順非依存 (要件 2-3)

    /// ON: `Query2<A, B>` と `Query2<B, A>` が同一フレームで同じ entity 集合を
    /// 観測することを確認します。
    @Test func query2TypeOrderDoesNotAffectMatchedEntitySet() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
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

        world.update(currentTime: 0)
        world.update(currentTime: 1)

        #expect(observedAB == [1, 2])
        #expect(observedAB == observedBA)
    }

    // MARK: - Entity ターゲット (要件 2-6)

    /// ON: `Query3<Entity, A, B>` がイテレーションで entity ID を渡すことを確認します。
    @Test func query3WithEntityTargetPassesEntityIDs() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        let target = commands.spawn()
            .addComponent(ComponentA(value: 7))
            .addComponent(ComponentB(text: "e"))
            .id()
        commands.spawn()
            .addComponent(ComponentA(value: 8))

        var observed = [(Entity, Int, String)]()
        world.addSystem(.update) { (query: Query3<Entity, ComponentA, ComponentB>) in
            guard observed.isEmpty else { return }
            query.update { entity, a, b in
                observed.append((entity, a.value, b.text))
            }
        }

        world.update(currentTime: 0)
        world.update(currentTime: 1)

        #expect(observed.count == 1)
        #expect(observed.first?.0 == target)
        #expect(observed.first?.1 == 7)
        #expect(observed.first?.2 == "e")
    }

    /// ON: Entity ターゲットを含む場合でも、column ターゲットへの変更は永続化される
    /// ことを確認します(Entity への書き込みは破棄されます)。
    @Test func query3MixedEntityAndColumnMutationPersistsForColumns() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        commands.spawn()
            .addComponent(ComponentA(value: 0))
            .addComponent(ComponentB(text: ""))

        var readBack = [[Int]]()
        world.addSystem(.update) { (query: Query3<Entity, ComponentA, ComponentB>) in
            var values = [Int]()
            query.update { _, a, _ in
                values.append(a.value)
                a.value += 10
            }
            readBack.append(values)
        }

        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        #expect(readBack == [[0], [10]])
    }

    // MARK: - entity 指定アクセス (要件 2-7)

    /// ON: `update(_:_:)` による対象 entity のみの読み書きと、
    /// `components(forEntity:)` での取得が動作することを確認します。
    @Test func query2TargetedUpdateAndComponentsForEntity() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        let target = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .addComponent(ComponentB(text: "t"))
            .id()
        let other = commands.spawn()
            .addComponent(ComponentA(value: 2))
            .addComponent(ComponentB(text: "o"))
            .id()

        var didWrite = false
        var results: [Int?]?
        world.addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
            if !didWrite {
                didWrite = true
                query.update(target) { a, b in
                    a.value = 10
                    b.text = "written"
                }
            } else if results == nil {
                results = [
                    query.components(forEntity: target)?.0.value,
                    query.components(forEntity: other)?.0.value,
                ]
                #expect(query.components(forEntity: target)?.1.text == "written")
                #expect(query.components(forEntity: other)?.1.text == "o")
            }
        }

        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        #expect(results == [10, 2])
    }

    /// ON: `Query2` の対象型を持たない entity への `update(_:_:)` /
    /// `components(forEntity:)` は no-op / nil であることを確認します。
    @Test func query2TargetedAccessToNonMatchingEntityIsNoOp() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        let onlyA = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()

        var called = false
        var result: (ComponentA, ComponentB)?
        world.addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
            query.update(onlyA) { _, _ in
                called = true
            }
            result = query.components(forEntity: onlyA)
        }

        world.update(currentTime: 0)
        world.update(currentTime: 1)

        #expect(called == false)
        #expect(result == nil)
    }

    // MARK: - despawn の反映 (要件 1-2 の Query ビュー)

    /// ON: despawn された entity が以降の `Query2` のイテレーションと
    /// `components(forEntity:)` から除外されることを確認します。
    @Test func query2DespawnedEntityIsNoLongerIterated() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .addComponent(ComponentB(text: "d"))
            .id()

        var perFrame = [[Int]]()
        world.addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
            var values = [Int]()
            query.update { a, _ in
                values.append(a.value)
            }
            perFrame.append(values)
        }

        world.update(currentTime: 0)
        world.update(currentTime: 1)

        commands.despawn(entity: entity)
        world.update(currentTime: 2)

        #expect(perFrame == [[1], []])

        let query = try #require(
            Query2<ComponentA, ComponentB>.getParameter(from: world.worldStorage)
        )
        #expect(query.components(forEntity: entity) == nil)
    }

    // MARK: - register 後に生成された Archetype の観測 (observer 経路)

    /// ON: Query2 の register 後、後続フレーム中の spawn で生成された Archetype が
    /// オブザーバ通知経由でマッチに追加されることを確認します。
    @Test func query2ObservesArchetypeCreatedAfterRegister() throws {
        let world = World(experimentalOptions: [.archetypeStorage])

        var spawned = false
        var perFrame = [[Int]]()
        world
            .addSystem(.update) { (commands: Commands) in
                guard !spawned else { return }
                spawned = true
                commands.spawn()
                    .addComponent(ComponentA(value: 5))
                    .addComponent(ComponentB(text: "late"))
            }
            .addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
                var values = [Int]()
                query.update { a, _ in
                    values.append(a.value)
                }
                perFrame.append(values)
            }

        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        // フレーム 1 では spawn は遅延適用のため空、フレーム 2 で見えます。
        #expect(perFrame == [[], [5]])
    }

    // MARK: - OFF 経路の維持 (要件 4-1)

    /// OFF: 従来の Query2 の挙動(イテレーション・変更の永続化・entity 指定取得)が
    /// 影響を受けないことを確認します(完全な保証は既存テストスイート全体の通過によります)。
    @Test func offWorldQuery2KeepsCurrentBehavior() throws {
        let world = World()
        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .addComponent(ComponentB(text: "off"))
            .id()

        var readBack = [Int?]()
        world.addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
            readBack.append(query.components(forEntity: entity)?.0.value)
            query.update { a, _ in
                a.value += 1
            }
        }

        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        #expect(readBack == [1, 2])
    }
}
