//
//  DoubleDespawnPathTests.swift
//  ECS_Swift
//
//  Created by rrbox on 2026/08/18.
//

import Testing
@testable import ECS

private struct Victim: Component {}

private final class Box {
    var victim: Entity?
    var spawned: [Entity] = []
    var despawnedFromRemoved = false
}

/// 二重 despawn が実際に成立する経路を確認するための検証用テスト.
///
/// 未修正のコードでは, 二重 despawn によって generator が汚染され,
/// その後の2回の spawn が同一 Entity ID を受け取る. したがって
/// `spawned[0] != spawned[1]` が失敗する経路は「二重 despawn が成立した」ことを意味する.
struct DoubleDespawnPathTests {
    /// A-2: 同一 phase の別々のシステムが, それぞれ Query 経由で同じ entity を despawn する.
    @Test func samePhaseTwoSystems() {
        let box = Box()
        let world = World()
            .addSystem(.startUp) { (commands: Commands) in
                box.victim = commands.spawn().addComponent(Victim()).id()
            }
            .addSystem(.update) { (
                victims: Filtered<Query<Entity>, With<Victim>>,
                commands: Commands,
                time: Resource<CurrentTime>
            ) in
                guard time.resource.value == 1 else { return }
                victims.update { entity in commands.despawn(entity: entity) }
            }
            .addSystem(.update) { (
                victims: Filtered<Query<Entity>, With<Victim>>,
                commands: Commands,
                time: Resource<CurrentTime>
            ) in
                guard time.resource.value == 1 else { return }
                victims.update { entity in commands.despawn(entity: entity) }
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == 2 else { return }
                box.spawned.append(commands.spawn().id())
                box.spawned.append(commands.spawn().id())
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        #expect(box.spawned[0] != box.spawned[1])
    }

    /// B: 同一フレームの update と postUpdate が, それぞれ同じ entity を despawn する.
    @Test func sameFrameDifferentPhases() {
        let box = Box()
        let world = World()
            .addSystem(.startUp) { (commands: Commands) in
                box.victim = commands.spawn().addComponent(Victim()).id()
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == 1, let victim = box.victim else { return }
                commands.despawn(entity: victim)
            }
            .addSystem(.postUpdate) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == 1, let victim = box.victim else { return }
                commands.despawn(entity: victim)
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == 2 else { return }
                box.spawned.append(commands.spawn().id())
                box.spawned.append(commands.spawn().id())
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        #expect(box.spawned[0] != box.spawned[1])
    }

    /// Removed: `.removed` スケジュールで受け取った entity を despawn する.
    @Test func despawnEntityReceivedFromRemoved() {
        let box = Box()
        let world = World()
            .addSystem(.startUp) { (commands: Commands) in
                box.victim = commands.spawn().addComponent(Victim()).id()
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == 1, let victim = box.victim else { return }
                commands.despawn(entity: victim)
            }
            .addSystem(.removed) { (removed: Removed, commands: Commands) in
                guard !box.despawnedFromRemoved else { return }
                box.despawnedFromRemoved = true
                removed.forEach { commands.despawn(entity: $0) }
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == 2 else { return }
                box.spawned.append(commands.spawn().id())
                box.spawned.append(commands.spawn().id())
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        #expect(box.despawnedFromRemoved)
        #expect(box.spawned[0] != box.spawned[1])
    }
}
