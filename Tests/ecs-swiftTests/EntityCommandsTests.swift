//
//  EntityCommandsTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

import XCTest
@testable import ECS

final class EntityCommandsTests: XCTestCase {
    func testEntityCommands() {
        let world = World()
        let commands = world.worldStorage.commands

        // world に entity を生成し, component を追加し, id(id としての entity) を受け取ります.
        let entity = commands.spawn()
            .addComponent(TestComponent(content: "test"))
            .id()
        commands.spawn()
            .addComponent(TestComponent(content: "test_2"))

        world.update(currentTime: 0)

        XCTAssertEqual(world.entityRecord(forEntity: entity)!.ref(TestComponent.self)!.value.content, "test")

        commands.entity(entity).removeComponent(ofType: TestComponent.self)

        world.update(currentTime: 0)

        // world 内に entity が存在し, component が削除されていることをテストします.
        XCTAssertNotNil(world.entityRecord(forEntity: entity))
        XCTAssertNil(world.entityRecord(forEntity: entity)!.ref(TestComponent.self))

        commands.despawn(entity: entity)

        world.update(currentTime: 0)

        // world から entity が削除されたことをテストします.
        XCTAssertNil(world.entityRecord(forEntity: entity))
    }
}
