//
//  EntityCommandsTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

#if DEBUG

import XCTest
@testable import ECS

final class EntityCommandsTests: XCTestCase {
    func testEntityCommands() async {
        let commands = Commands()
        let world = World()
        world.worldStorage.commandsStorage.setCommands(commands)
        
        // world に entity を生成し, component を追加し, id(id としての entity) を受け取ります.
        let entity = await commands.spawn()
            .addComponent(TestComponent(content: "test"))
            .id()
        await world.applyCommands()
        
        XCTAssertEqual(world.entityRecord(forEntity: entity)!.componentRef(TestComponent.self)!.value.content, "test")
        
        await commands.entity(entity)?.removeComponent(ofType: TestComponent.self)
        await world.applyCommands()
        
        // world 内に entity が存在し, component が削除されていることをテストします.
        XCTAssertNotNil(world.entityRecord(forEntity: entity))
        XCTAssertNil(world.entityRecord(forEntity: entity)!.componentRef(TestComponent.self))
        
        await commands.despawn(entity: entity)
        await world.applyCommands()
        
        // world から entity が削除されたことをテストします.
        XCTAssertNil(world.entityRecord(forEntity: entity))
    }
}

#endif
