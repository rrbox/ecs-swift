//
//  SpawnCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class SpawnCommand: Command {
    let id: Entity
    let entityRecord: EntityRecord
    
    init(id: Entity, entityRecord: EntityRecord) {
        self.id = id
        self.entityRecord = entityRecord
    }
    
    override func runCommand(in world: World) {
        world.push(entity: self.id, entityRecord: self.entityRecord)
    }
}

