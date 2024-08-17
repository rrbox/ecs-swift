//
//  SystemTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

import XCTest
import ECS

func testSetUp(commands: Commands) {
    print("set up")
    commands.spawn()
        .addComponent(TestComponent(content: "sample_1010"))

    commands.spawn()
        .addComponent(TestComponent(content: "sample_120391-2"))
}

func currentTimeTestSystem(time: Resource<CurrentTime>) {
    print(time.resource)
}

func deltaTimeTestSystem(deltaTime: Resource<DeltaTime>) {
    print(deltaTime.resource)
}

func apiTestSystem(
    q0: Query<TestComponent>
) {
    q0.update { component in
        print(component)
    }
}

func apiTestSystem(
    q0: Query<TestComponent>,
    q1: Query2<TestComponent, TestComponent>
) {

}

func apiTestSystem(
    q0: Query<TestComponent>,
    q1: Query2<TestComponent, TestComponent>,
    q2: Query3<TestComponent, TestComponent, TestComponent>
) {

}

func apiTestSystem(
    q0: Query<TestComponent>,
    q1: Query2<TestComponent, TestComponent>,
    q2: Query3<TestComponent, TestComponent, TestComponent>,
    q3: Query4<TestComponent, TestComponent, TestComponent, TestComponent>
) {

}

func apiTestSystem(
    q0: Query<TestComponent>,
    q1: Query2<TestComponent, TestComponent>,
    q2: Query3<TestComponent, TestComponent, TestComponent>,
    q3: Query4<TestComponent, TestComponent, TestComponent, TestComponent>,
    q4: Query5<TestComponent, TestComponent, TestComponent, TestComponent, TestComponent>
) {
    q0.update { component in
        print(component)
    }
}

final class SystemTests: XCTestCase {
    func testUpdateSystem() {
        let world = World()
            .addSystem(.startUp, testSetUp(commands:))
            .addSystem(.update, currentTimeTestSystem(time:))
            .addSystem(.update, deltaTimeTestSystem(deltaTime:))
            .addSystem(.update, apiTestSystem(q0:))
            .addSystem(.update, apiTestSystem(q0:q1:))
            .addSystem(.update, apiTestSystem(q0:q1:q2:))
            .addSystem(.update, apiTestSystem(q0:q1:q2:q3:))
            .addSystem(.update, apiTestSystem(q0:q1:q2:q3:q4:))

        world.setUpWorld()

        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)
        world.update(currentTime: 3)
        world.update(currentTime: 4)
    }
}
