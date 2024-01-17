//
//  UpdateSystemTests.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

import XCTest
import ECS

func mySystem(commands: Commands) async {
    await commands.spawn()
        .addComponent(TestComponent(content: "sample"))
}

func mySystem2(query: Query<TestComponent>) async {
    await query.update { _, component in
        XCTAssertEqual(component.content, "sample")
    }
}

final class UpdateSystemTests: XCTestCase {
    func testUpdate() async {
        let world = await World()
            .addSystem(.update, mySystem(commands:))
            .addSystem(.update, mySystem2(query:))
        
        
        await world.update(currentTime: 0)
        await world.update(currentTime: 0)
    }
}
