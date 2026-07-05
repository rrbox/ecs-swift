//
//  StaleHandleReproTests.swift
//
//
//  issue #165 の再現ケース. 修正前は debug ビルドで assertion failure により
//  テストプロセスごとクラッシュした. 修正後は stale ハンドルでの despawn が
//  no-op となり, slot を再利用した新しい entity が誤って削除されないことを検証する.
//

import Testing
@testable import ECS

private struct ReproMarker: Component { let tag: String }

private final class Box {
    var entities: [Entity] = []
    var survivedTags: [String] = []
}

struct StaleHandleReproTests {
    @Test func staleHandleDespawnDoesNotDestroyReusedSlot() {
        let box = Box()
        let world = World()
            .addSystem(.startUp) { (commands: Commands) in
                let e = commands.spawn().addComponent(ReproMarker(tag: "gen0")).id()
                box.entities.append(e)
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                switch time.resource.value {
                case 1:
                    commands.despawn(entity: box.entities[0]) // (slot: n, gen: 0) を削除
                case 2:
                    commands.spawn().addComponent(ReproMarker(tag: "gen1")) // slot 再利用: (slot: n, gen: 1)
                case 3:
                    // stale ハンドル (gen: 0) で despawn.
                    // 修正後は contains が世代不一致を弾き, pop は no-op になる.
                    commands.despawn(entity: box.entities[0])
                default:
                    break
                }
            }
            .addSystem(.postUpdate) { (query: Query<ReproMarker>) in
                var tags: [String] = []
                query.update { tags.append($0.tag) }
                box.survivedTags = tags
            }

        for t in 0...4 {
            world.update(currentTime: Double(t))
        }

        // gen1 の entity は stale despawn の影響を受けず生存している.
        #expect(box.survivedTags == ["gen1"])
    }
}
