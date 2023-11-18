//
//  SpawnCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class SpawnCommand: EntityCommand {
    let entityRecord: EntityRecordRef
    
    init(id: Entity, entityRecord: EntityRecordRef) {
        self.entityRecord = entityRecord
        super.init(entity: id)
    }
    
    override func runCommand(in world: World) {
        world.push(entity: self.entity, entityRecord: self.entityRecord)
    }
}

