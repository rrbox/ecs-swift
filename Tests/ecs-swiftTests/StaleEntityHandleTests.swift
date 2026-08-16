//
//  StaleEntityHandleTests.swift
//  ECS_Swift
//
//  Created by rrbox on 2026/08/16.
//

import Testing
@testable import ECS

private final class EntityHandleBox {
    var handle: Entity?
}

struct StaleEntityHandleTests {
    @Test func despawnWithStaleHandleKeepsEntityReusingSlot() {
        let despawnFrame = 1.0
        let reuseSlotFrame = 2.0
        let staleDespawnFrame = 3.0
        let lastFrame = 4.0

        let firstSpawned = EntityHandleBox()
        let world = World()
            .addSystem(.startUp) { (commands: Commands) in
                firstSpawned.handle = commands.spawn()
                    .addComponent(TestComponent(content: "despawned"))
                    .id()
            }
            .addSystem(.update) { (commands: Commands, time: Resource<CurrentTime>) in
                guard let staleHandle = firstSpawned.handle else { return }
                switch time.resource.value {
                case despawnFrame:
                    commands.despawn(entity: staleHandle)
                case reuseSlotFrame:
                    commands.spawn().addComponent(TestComponent(content: "reusing slot"))
                case staleDespawnFrame:
                    commands.despawn(entity: staleHandle)
                default:
                    break
                }
            }

        for frame in stride(from: 0.0, through: lastFrame, by: 1.0) {
            world.update(currentTime: frame)
        }

        #expect(self.testComponentContents(in: world) == ["reusing slot"])
    }

    private func testComponentContents(in world: World) -> [String] {
        var contents: [String] = []
        world.entities.update { (record: inout EntityRecordRef) in
            if let ref = record.ref(TestComponent.self) {
                contents.append(ref.value.content)
            }
        }
        return contents.sorted()
    }
}
