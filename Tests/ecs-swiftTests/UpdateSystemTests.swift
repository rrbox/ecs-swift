//
//  UpdateSystemTests.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

import XCTest
@testable import ECS

func mySystem(commands: Commands) {
    commands.spawn()
        .addComponent(TestComponent(content: "sample"))
}

func mySystem2(query: Query<TestComponent>) {
    query.update { component in
        XCTAssertEqual(component.content, "sample")
    }
}

final class UpdateSystemTests: XCTestCase {
    func testUpdate() {
        let world = World()
            .addSystem(.update, mySystem(commands:))
            .addSystem(.update, mySystem2(query:))

        world.update(currentTime: 0)
        world.update(currentTime: 0)
    }
}
