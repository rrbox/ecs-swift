//
//  CommandsTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

#if DEBUG

import XCTest
@testable import ECS

class TestCommand_Spawn: Command {
    let entity: Entity
    init(entity: Entity) {
        self.entity = entity
    }
    override func runCommand(in world: World) async {
        await world.push(entity: self.entity, entityRecord: EntityRecordRef())
    }
}

class TestCommand_Despawn: Command {
    let entity: Entity
    init(entity: Entity) {
        self.entity = entity
    }
    override func runCommand(in world: World) async {
        await world.despawn(entity: self.entity)
    }
}

final class CommandsTests: XCTestCase {
    func testCommands() async {
        let world = World()
        world.worldStorage.commandsStorage.setCommands(Commands())
        let commands = world.worldStorage.commandsStorage.commands()!
        
        let testEntities = [Entity(), Entity(), Entity()]
        
        for testEntity in testEntities {
            await commands.push(command: TestCommand_Spawn(entity: testEntity))
        }
        
        var commandsCount = await commands.commandQueue.count
        XCTAssertEqual(commandsCount, 3)
        await world.applyCommands()
        
        commandsCount = await commands.commandQueue.count
        XCTAssertEqual(commandsCount, 0)
        XCTAssertEqual(world.entities.sequence.count, 3)
        
        for testEntity in testEntities {
            await commands.push(command: TestCommand_Despawn(entity: testEntity))
        }
        
        commandsCount = await commands.commandQueue.count
        XCTAssertEqual(commandsCount, 3)
        await world.applyCommands()
        
        commandsCount = await commands.commandQueue.count
        XCTAssertEqual(commandsCount, 0)
        XCTAssertEqual(world.entities.sequence.count, 0)
    }
}

#endif
