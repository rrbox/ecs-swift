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
        world.push(entityRecord: EntityRecordRef(entity: entity))
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
        let commands = world.worldStorage.commands

        let testEntities = [Entity(slot: 0, generation: 0), Entity(slot: 1, generation: 0), Entity(slot: 2, generation: 0)]

        for testEntity in testEntities {
            commands.push(command: TestCommand_Spawn(entity: testEntity))
        }

        XCTAssertEqual(commands.commandQueue.count, 3)
        world.applyCommands(commands: commands)

        XCTAssertEqual(commands.commandQueue.count, 0)
        XCTAssertEqual(world.entities.data.count, 3)

        for testEntity in testEntities {
            commands.push(command: TestCommand_Despawn(entity: testEntity))
        }

        XCTAssertEqual(commands.commandQueue.count, 3)
        world.applyCommands(commands: commands)

        XCTAssertEqual(commands.commandQueue.count, 0)
        XCTAssertEqual(world.entities.data.count, 0)
    }
}
