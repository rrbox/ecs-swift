//
//  LateQueryReproTests.swift
//
//  Regression tests for issue #166:
//  spawn 後に登録された Query が既存 entity を認識せず, 次の spawn で index out of range クラッシュする.
//

import Testing
import ECS

private struct LateComponent: Component {}

private final class Box { var count = -1 }

struct LateQueryReproTests {
    @Test func lateRegisteredQueryCrashesOnNextSpawn() {
        let box = Box()
        let world = World()
            .addSystem(.startUp) { (commands: Commands) in
                commands.spawn().addComponent(LateComponent()) // e0: (slot 0, gen 0)
            }
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        // spawn 後に新しい Query 型のシステムを追加
        world.addSystem(.update) { (query: Query<LateComponent>) in
            var c = 0
            query.update { _ in c += 1 }
            box.count = c
        }
        world.addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
            if time.resource.value == 3 {
                commands.spawn().addComponent(LateComponent()) // e1: (slot 1, gen 0)
            }
        }
        world.update(currentTime: 2)
        // 既存 entity e0 は遅延登録された Query から見える(バックフィル)
        #expect(box.count == 1, "late-registered query must see pre-existing entities")
        world.update(currentTime: 3) // e1 の spawn を sparse に反映してもクラッシュしない
        world.update(currentTime: 4)
        // e0 + e1 の 2 件が見えている
        #expect(box.count == 2, "late-registered query must see entities spawned after registration")
    }
}
