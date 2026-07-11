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
    // タスク 7.2: 新旧両バックエンドで実行されます。
    func testUpdate() {
        for backend in WorldBackend.allCases {
            let world = backend.makeWorld()
                .addSystem(.update, mySystem(commands:))
                .addSystem(.update, mySystem2(query:))

            world.update(currentTime: 0)
            world.update(currentTime: 0)
        }
    }
}
