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
    for event in event.events {
        print("---test event read---")
        print("frame:", currentTime.resource.value)
        print("<- read event:", event.name)
        let spawned = commands.spawn().addComponent(TestComponent(content: event.name)).id()
        print("-> spawn:", spawned)
        print("-> event send:", "\"link\"")
        eventWriter.send(value: TestEvent(name: "[\(currentTime.resource.value)]: link"))
        print("---")
        print()
    }
}

func setUp(eventWriter: EventWriter<TestEvent>) {
    print("---set up---")
    print("-> event send:", "\"test event\"")
    eventWriter.send(value: TestEvent(name: "test event"))
    print("---")
    print()
}

func spawnedEntitySystem(eventReader: EventReader<DidSpawnEvent>, commands: Commands, currentTime: Resource<CurrentTime>) {
    for event in eventReader.events {
        print("---spawned entity event read---")
        print("frame:", currentTime.resource.value)
        print("<- spawned(receive):", event.spawnedEntity)
        print("-> despawn:", event.spawnedEntity)
        commands.despawn(entity: event.spawnedEntity)
        print("---")
        print()
    }
}

func despanedEntitySystem(eventReader: EventReader<WillDespawnEvent>, commands: Commands, currentTime: Resource<CurrentTime>) {
    for event in eventReader.events {
        print("---despawned entity event read---")
        print("frame:", currentTime.resource.value)
        print("<- despawned(receive):", event.despawnedEntity)
        print("---")
        print()
    }
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
        world.update(currentTime: -1)

        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)
        world.update(currentTime: 3)
    }

    func testEventStream() {
        var flags = [0, 0, 0, 0]

        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .addSystem(.startUp, { (eventWriter: EventWriter<TestEvent>) in
                eventWriter.send(value: .init(name: "test event"))
                ECSTAssertStepOrder(currentStep: 0, steps: &flags)
            })
            .buildEventResponder(TestEvent.self) { responder in
                responder.addSystem(.update) { (event: EventReader<TestEvent>, commands: Commands) in
                    for event in event.events {
                        ECSTAssertStepOrder(currentStep: 1, steps: &flags)
                        commands.spawn().addComponent(TestComponent(content: event.name))
                    }
                }
            }
            .buildDidSpawnResponder { responder in
                responder
                    .addSystem(.update) { (event: EventReader<DidSpawnEvent>, commands: Commands) in
                        for event in event.events {
                            ECSTAssertStepOrder(currentStep: 2, steps: &flags)
                            commands.despawn(entity: event.spawnedEntity)
                        }
                    }
            }
            .buildWillDespawnResponder { responder in
                responder
                    .addSystem(.update) { (event: EventReader<WillDespawnEvent>) in
                        ECSTAssertStepOrder(currentStep: 3, steps: &flags)
                    }
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)

        XCTAssertEqual(flags, [1, 1, 1, 1])
    }

    func testSendTwoEventsInOneUpdate() {
        var count = 0

        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .addSystem(.startUp, { (eventWriter: EventWriter<TestEvent>) in
                eventWriter.send(value: .init(name: "event 1"))
                eventWriter.send(value: .init(name: "event 2"))
            })
            .buildEventResponder(TestEvent.self) { responder in
                responder.addSystem(.update) { (event: EventReader<TestEvent>) in
                    count += event.events.count
                }
            }

        world.setUpWorld()
        world.update(currentTime: 0)

        XCTAssertEqual(count, 2)
    }

    func testSystemExecutesOnceWithTwoEvents() {
        var executionCount = 0

        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .addSystem(.startUp, { (eventWriter: EventWriter<TestEvent>) in
                eventWriter.send(value: .init(name: "event 1"))
                eventWriter.send(value: .init(name: "event 2"))
            })
            .buildEventResponder(TestEvent.self) { responder in
                responder.addSystem(.update) { (_: EventReader<TestEvent>) in
                    executionCount += 1
                }
            }

        world.setUpWorld()
        world.update(currentTime: 0)

        XCTAssertEqual(executionCount, 1)
    }
}
