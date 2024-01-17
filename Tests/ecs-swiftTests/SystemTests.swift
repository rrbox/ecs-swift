//
//  SystemTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

import XCTest
import ECS

func testSetUp(commands: Commands) async {
    print("set up")
    await commands.spawn()
        .addComponent(TestComponent(content: "sample_1010"))
    
    await commands.spawn()
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
) async {
    await q0.update { _, component in
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
) async {
    await q0.update { _, component in
        print(component)
    }
}

final class SystemTests: XCTestCase {
    func testUpdateSystem() async {
        let world = await World()
            .addSystem(.startUp, testSetUp(commands:))
            .addSystem(.update, currentTimeTestSystem(time:))
            .addSystem(.update, deltaTimeTestSystem(deltaTime:))
            .addSystem(.update, apiTestSystem(q0:))
            .addSystem(.update, apiTestSystem(q0:q1:))
            .addSystem(.update, apiTestSystem(q0:q1:q2:))
            .addSystem(.update, apiTestSystem(q0:q1:q2:q3:))
            .addSystem(.update, apiTestSystem(q0:q1:q2:q3:q4:))
        
        await world.setUpWorld()
        
        await world.update(currentTime: 0)
        await world.update(currentTime: 1)
        await world.update(currentTime: 2)
        await world.update(currentTime: 3)
        await world.update(currentTime: 4)
    }
}
