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

enum EventTestState: StateProtocol {
    case stateA
    case stateB
    case stateC
}

func testEvent(
    events: EventReaderV2<TestEvent>,
    eventWriter: EventWriterV2<TestEvent>,
    commands: Commands,
    currentTime: Resource<CurrentTime>
) {
    events.forEach { event in
        print("---test event read---")
        print("frame:", currentTime.resource.value)
        print("<- read event:", event.name)
        let spawned = commands.spawn().addComponent(TestComponent(content: event.name)).id()
        print("-> spawn:", spawned)
        print("-> event send:", "\"link\"")
        eventWriter.send(TestEvent(name: "[\(currentTime.resource.value)]: link"))
        print("---")
        print()
    }
}

func setUp(eventWriter: EventWriterV2<TestEvent>) {
    print("---set up---")
    print("-> event send:", "\"test event\"")
    eventWriter.send(TestEvent(name: "test event"))
    print("---")
    print()
}

func spawnedEntitySystem(
    events: EventReaderV2<Spawned>,
    commands: Commands,
    currentTime: Resource<CurrentTime>
) {
    events.forEach { event in
        print("---spawned entity event read---")
        print("frame:", currentTime.resource.value)
        print("<- spawned(receive):", event.spawnedEntity)
        print("-> despawn:", event.spawnedEntity)
        commands.despawn(entity: event.spawnedEntity)
        print("---")
        print()
    }
}

func despanedEntitySystem(
    removed: Removed,
    commands: Commands,
    currentTime: Resource<CurrentTime>
) {
    removed.forEach { removedEntity in
        print("---despawned entity event read---")
        print("frame:", currentTime.resource.value)
        print("<- despawned(receive):", removedEntity)
        print("---")
        print()
    }
}

final class EventTests: XCTestCase {
    func testEvent() {
        print()

        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .addSystem(.update, testEvent(events:eventWriter:commands:currentTime:))
            .addSystem(.startUp, setUp(eventWriter:))
            .addSystem(.update, spawnedEntitySystem(events:commands:currentTime:))
            .addSystem(.removed, despanedEntitySystem(removed:commands:currentTime:))

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
            .addSystem(.startUp) { (eventWriter: EventWriterV2<TestEvent>) in
                eventWriter.send(.init(name: "test event"))
                ECSTAssertStepOrder(currentStep: 0, steps: &flags)
            }
            .addSystem(.update) { (event: EventReaderV2<TestEvent>, commands: Commands) in
                event.forEach { event in
                    ECSTAssertStepOrder(currentStep: 1, steps: &flags)
                    commands.spawn().addComponent(TestComponent(content: event.name))
                }
            }
            .addSystem(.removed) { (removed: Removed, query: Query<TestComponent>) in
                ECSTAssertStepOrder(currentStep: 3, steps: &flags)
            }
            .addSystem(.update) { (events: EventReaderV2<Spawned>, commands: Commands) in
                events.forEach { spawned in
                    ECSTAssertStepOrder(currentStep: 2, steps: &flags)
                    commands.despawn(entity: spawned.spawnedEntity)
                }
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        XCTAssertEqual(flags, [1, 1, 1, 1])
    }

    func testSendTwoEventsInOneUpdate() {
        var receivedEventCounts = [0, 0]
        var flags = [0, 0, 0]

        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .addSystem(.startUp, { (eventWriter: EventWriterV2<TestEvent>) in
                eventWriter.send(.init(name: "event 1"))
                eventWriter.send(.init(name: "event 2"))
                ECSTAssertStepOrder(currentStep: 0, steps: &flags)
            })
            .addSystem(.postStartUp, { (events: EventReaderV2<TestEvent>) in
                receivedEventCounts[0] += events.count
                ECSTAssertStepOrder(currentStep: 1, steps: &flags)
            })
            .addSystem(.update) { (events: EventReaderV2<TestEvent>) in
                receivedEventCounts[1] += events.count
                if !events.isEmpty {
                    ECSTAssertStepOrder(currentStep: 2, steps: &flags)
                }
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        XCTAssertEqual(receivedEventCounts, [2, 2])
        XCTAssertEqual(flags, [1, 1, 1])
    }

    func testSystemExecutesOnceWithTwoEvents() {
        var executionCount = 0

        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .addSystem(.startUp) { (eventWriter: EventWriterV2<TestEvent>) in
                eventWriter.send(.init(name: "event 1"))
                eventWriter.send(.init(name: "event 2"))
            }
            .addSystem(.update) { (events: EventReaderV2<TestEvent>) in
                if !events.isEmpty {
                    executionCount += 1
                }
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)

        XCTAssertEqual(executionCount, 1)
    }

    func testRemovedOnEvent() {
        var flags = [0, 0, 0]
        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .addState(initialState: EventTestState.stateA, states: [
                .stateA, .stateB, .stateC
            ])
            .addSystem(.startUp) { (commands: Commands, state: State<EventTestState>) in
                commands.spawn()
                state.enter(.stateA)
            }
            .addSystem(.update) { (spawned: EventReaderV2<Spawned>, commands: Commands) in
                spawned.forEach { event in
                    commands.despawn(entity: event.spawnedEntity)
                }
            }
            .addSystem(.removedOn(EventTestState.stateA)) { (removed: Removed, commands: Commands, state: State<EventTestState>) in
                ECSTAssertStepOrder(currentStep: 0, steps: &flags)
                state.enter(.stateB)
                commands.spawn()
            }
            .addSystem(.removedOn(EventTestState.stateB)) { (removed: Removed, commands: Commands, state: State<EventTestState>) in
                ECSTAssertStepOrder(currentStep: 1, steps: &flags)
                state.push(.stateC)
                commands.spawn()
            }
            .addSystem(.removedOn(EventTestState.stateC)) { (removed: Removed) in
                ECSTAssertStepOrder(currentStep: 2, steps: &flags)
            }
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)
        XCTAssertEqual(flags, [1, 1, 1])
    }

    func testRemovedOnStackEvent() {
        var flagsA = [0, 0]
        var flagsB = [0, 0]
        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .addState(initialState: EventTestState.stateA, states: [
                .stateA, .stateB
            ])
            .addSystem(.startUp) { (commands: Commands, state: State<EventTestState>) in
                commands.spawn()
            }
            .addSystem(.update) { (spawned: EventReaderV2<Spawned>, commands: Commands) in
                spawned.forEach { event in
                    commands.despawn(entity: event.spawnedEntity)
                }
            }
            .addSystem(.removedOnStack(EventTestState.stateA)) { (removed: Removed, commands: Commands, state: State<EventTestState>, currentTime: Resource<CurrentTime>) in
                switch currentTime.resource.value {
                case -1: XCTFail()
                case 0:
                    ECSTAssertStepOrder(currentStep: 0, steps: &flagsA)
                    ECSTAssertStepOrder(currentStep: 0, steps: &flagsB)
                    state.push(.stateB)
                    commands.spawn()
                case 1:
                    ECSTAssertStepOrder(currentStep: 1, steps: &flagsA)
                default:
                    XCTFail()
                }
            }
            .addSystem(.removedOnStack(EventTestState.stateB)) { (removed: Removed, commands: Commands, state: State<EventTestState>) in
                ECSTAssertStepOrder(currentStep: 1, steps: &flagsB)
                commands.spawn()
            }
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        XCTAssertEqual(flagsA, [1, 1])
        XCTAssertEqual(flagsB, [1, 1])
    }

    func testRemovedOnInactiveEvent() {
        var flags = [0, 0]
        let world = World()
            .addEventStreamer(eventType: TestEvent.self)
            .addState(initialState: EventTestState.stateA, states: [
                .stateA, .stateB
            ])
            .addSystem(.startUp) { (commands: Commands, state: State<EventTestState>) in
                commands.spawn()
                state.enter(.stateA)
            }
            .addSystem(.update) { (spawned: EventReaderV2<Spawned>, commands: Commands) in
                spawned.forEach { event in
                    commands.despawn(entity: event.spawnedEntity)
                }
            }
            .addSystem(.removedOn(EventTestState.stateA)) { (removed: Removed, commands: Commands, state: State<EventTestState>) in
                ECSTAssertStepOrder(currentStep: 0, steps: &flags)
                state.push(.stateB)
                commands.spawn()
            }
            .addSystem(.removedOnInactive(EventTestState.stateA), { (removed: Removed) in
                ECSTAssertStepOrder(currentStep: 1, steps: &flags)
            })
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        XCTAssertEqual(flags, [1, 1])
    }
}
