//
//  CommandsTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

import XCTest
@testable import ECS

class TestCommand_Spawn: Command {
    let entity: Entity
    init(entity: Entity) {
        self.entity = entity
    }
    override func runCommand(in world: World) {
        world.push(entity: self.entity, entityRecord: EntityRecord())
    }
}

class TestCommand_Despawn: Command {
    let entity: Entity
    init(entity: Entity) {
        self.entity = entity
    }
    override func runCommand(in world: World) {
        world.despawn(entity: self.entity)
    }
}

final class CommandsTests: XCTestCase {
    func testCommands() {
        let world = World()
        world.worldBuffer.commandsBuffer.setCommands(Commands())
        let commands = world.worldBuffer.commandsBuffer.commands()!
        
        let testEntities = [Entity(), Entity(), Entity()]
        
        for testEntity in testEntities {
            commands.push(command: TestCommand_Spawn(entity: testEntity))
        }
        
        XCTAssertEqual(commands.commandQueue.count, 3)
        world.applyCommands()
        
        XCTAssertEqual(commands.commandQueue.count, 0)
        XCTAssertEqual(world.entities.sequence.count, 3)
        
        for testEntity in testEntities {
            commands.push(command: TestCommand_Despawn(entity: testEntity))
        }
        
        XCTAssertEqual(commands.commandQueue.count, 3)
        world.applyCommands()
        
        XCTAssertEqual(commands.commandQueue.count, 0)
        XCTAssertEqual(world.entities.sequence.count, 0)
    }
}
