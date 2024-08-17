//
//  EventTests.swift
//  
//
//  Created by rrbox on 2023/08/13.
//

import XCTest
@testable import ECS

struct TestEvent: EventProtocol {
    let name: String
}

func testEvent(event: EventReader<TestEvent>, eventWriter: EventWriter<TestEvent>, commands: Commands, currentTime: Resource<CurrentTime>) {
    print("---test event read---")
    print("frame:", currentTime.resource.value)
    print("<- read event:", event.value.name)
    let spawned = commands.spawn().addComponent(TestComponent(content: event.value.name)).id()
    print("-> spawn:", spawned)
    print("-> event send:", "\"link\"")
    eventWriter.send(value: TestEvent(name: "[\(currentTime.resource.value)]: link"))
    print("---")
    print()
}

func setUp(eventWriter: EventWriter<TestEvent>) {
    print("---set up---")
    print("-> event send:", "\"test event\"")
    eventWriter.send(value: TestEvent(name: "test event"))
    print("---")
    print()
}

func spawnedEntitySystem(eventReader: EventReader<DidSpawnEvent>, commands: Commands, currentTime: Resource<CurrentTime>) {
    print("---spawned entity event read---")
    print("frame:", currentTime.resource.value)
    print("<- spawned(receive):", eventReader.value.spawnedEntity)
    print("-> despawn:", eventReader.value.spawnedEntity)
    commands.despawn(entity: eventReader.value.spawnedEntity)
    print("---")
    print()
}

func despanedEntitySystem(eventReader: EventReader<WillDespawnEvent>, commands: Commands, currentTime: Resource<CurrentTime>) {
    print("---despawned entity event read---")
    print("frame:", currentTime.resource.value)
    print("<- despawned(receive):", eventReader.value.despawnedEntity)
    print("---")
    print()
}

final class EventTests: XCTestCase {
    func testEvent() {
        print()

        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .buildEventResponder(TestEvent.self, { responder in
                responder.addSystem(.update, testEvent(event:eventWriter:commands:currentTime:))
            })
            .addSystem(.startUp, setUp(eventWriter:))
            .addSystem(.didSpawn, spawnedEntitySystem(eventReader:commands:currentTime:))
            .addSystem(.willDespawn, despanedEntitySystem(eventReader:commands:currentTime:))

        world.setUpWorld()

        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)
        world.update(currentTime: 3)
    }
}
