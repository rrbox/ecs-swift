//
//  UsageTest.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/07/04.
//

import Testing
import ECS

struct UsageTest {

    // MARK: - Custom Resource

    struct TestResource: ResourceProtocol {
        let state: String
    }

    // MARK: - Custom State

    enum TestState: StateProtocol {
        case title
        case inGame
        case end
    }

    // MARK: - Custom Parameter

    final class SampleParameter: SystemParameter, AdditionalStorageElement {

        static func register(to worldStorage: ECS.WorldStorageRef) {
            guard worldStorage.additionalStorage.valueRef(ofType: Self.self) == nil else {
                return
            }
            worldStorage.additionalStorage.push(SampleParameter())
        }

        static func getParameter(from worldStorage: ECS.WorldStorageRef) -> Self? {
            worldStorage.additionalStorage.valueRef(ofType: Self.self)!.body
        }

    }

    // MARK: - Custom Systems

    func startUp(commands: Commands) {
        commands.spawn()
            .addComponent(TestComponent(content: "test0"))
        commands.spawn()
            .addComponent(TestComponent(content: "test1"))
        commands.spawn()
            .addComponent(TestComponent(content: "test2"))
            .addComponent(TestComponent2(content: "test2"))
    }

    func update(query: Query<TestComponent>) {
        query.update { component in
            print(component.content)
        }
    }

    func update(
        commands: Commands,
        query: Filtered<Query2<Entity, TestComponent>, With<TestComponent2>>,
        currentTime: Resource<CurrentTime>
    ) {
        if currentTime.resource.value == 5 {
            query.update { entity, _ in
                commands.entity(entity)
                    .addComponent(TestComponent3(content: "search test"))
                    .removeComponent(ofType: TestComponent2.self)
            }
        }
    }

    func inGameUpdate(query: Query<TestComponent2>, currentTime: Resource<CurrentTime>, stateMachine: State<TestState>) {
        query.update { component in
            print(component.content)
        }

        if currentTime.resource.value == 6 {
            stateMachine.enter(.end)
        }
    }

    func update(resource: Resource<TestResource>) {
        resource.resource = .init(state: "update")
    }

    func access(sampleParameter: SampleParameter, currentTime: Resource<CurrentTime>) {
        if currentTime.resource.value == 7 {
            print(sampleParameter)
        }
    }

    // MARK: - Use

    @Test func usage() async throws {
        let world = World()
            .addResource(TestResource(state: "start"))
            .addState(initialState: TestState.title, states: [.title, .inGame, .end])
            .addSystem(.update, update(query:))
            .addSystem(.update, update(commands:query:currentTime:))
            .addSystem(.onUpdate(TestState.inGame), inGameUpdate(query:currentTime:stateMachine:))
            .addSystem(.update, access(sampleParameter:currentTime:))

        world.setUpWorld()

        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)
        world.update(currentTime: 3)
        world.update(currentTime: 4)
        world.update(currentTime: 5)
        world.update(currentTime: 6)
        world.update(currentTime: 7)
        world.update(currentTime: 8)
        world.update(currentTime: 9)
    }

}
