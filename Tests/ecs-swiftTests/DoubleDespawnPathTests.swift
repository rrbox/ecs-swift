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
    var spawnedAfterDoubleDespawn: [Entity] = []
    var didDespawnFromRemovedSchedule = false
}

private let despawnFrame = 1.0
private let spawnFrame = 2.0

struct DoubleDespawnPathTests {
    @Test func twoSystemsInSamePhaseDespawnSameEntity() {
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
                guard time.resource.value == despawnFrame else { return }
                victims.update { entity in commands.despawn(entity: entity) }
            }
            .addSystem(.update) { (
                victims: Filtered<Query<Entity>, With<Victim>>,
                commands: Commands,
                time: Resource<CurrentTime>
            ) in
                guard time.resource.value == despawnFrame else { return }
                victims.update { entity in commands.despawn(entity: entity) }
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == spawnFrame else { return }
                box.spawnedAfterDoubleDespawn.append(commands.spawn().id())
                box.spawnedAfterDoubleDespawn.append(commands.spawn().id())
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: despawnFrame)
        world.update(currentTime: spawnFrame)

        #expect(box.spawnedAfterDoubleDespawn[0] != box.spawnedAfterDoubleDespawn[1])
    }

    @Test func updateAndPostUpdateDespawnSameEntity() {
        let box = Box()
        let world = World()
            .addSystem(.startUp) { (commands: Commands) in
                box.victim = commands.spawn().addComponent(Victim()).id()
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == despawnFrame, let victim = box.victim else { return }
                commands.despawn(entity: victim)
            }
            .addSystem(.postUpdate) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == despawnFrame, let victim = box.victim else { return }
                commands.despawn(entity: victim)
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == spawnFrame else { return }
                box.spawnedAfterDoubleDespawn.append(commands.spawn().id())
                box.spawnedAfterDoubleDespawn.append(commands.spawn().id())
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: despawnFrame)
        world.update(currentTime: spawnFrame)

        #expect(box.spawnedAfterDoubleDespawn[0] != box.spawnedAfterDoubleDespawn[1])
    }

    @Test func despawnEntityReceivedFromRemovedSchedule() {
        let box = Box()
        let world = World()
            .addSystem(.startUp) { (commands: Commands) in
                box.victim = commands.spawn().addComponent(Victim()).id()
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == despawnFrame, let victim = box.victim else { return }
                commands.despawn(entity: victim)
            }
            .addSystem(.removed) { (removed: Removed, commands: Commands) in
                guard !box.didDespawnFromRemovedSchedule else { return }
                box.didDespawnFromRemovedSchedule = true
                removed.forEach { commands.despawn(entity: $0) }
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == spawnFrame else { return }
                box.spawnedAfterDoubleDespawn.append(commands.spawn().id())
                box.spawnedAfterDoubleDespawn.append(commands.spawn().id())
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: despawnFrame)
        world.update(currentTime: spawnFrame)

        #expect(box.didDespawnFromRemovedSchedule)
        #expect(box.spawnedAfterDoubleDespawn[0] != box.spawnedAfterDoubleDespawn[1])
    }
}
