//
//  SpawnCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class SpawnCommand: Command {
    let id: Entity
    let value: Archetype
    
    init(id: Entity, value: Archetype) {
        self.id = id
        self.value = value
    }
    
    override func runCommand(in world: World) {
        world.push(entity: self.id, value: self.value)
    }
}

