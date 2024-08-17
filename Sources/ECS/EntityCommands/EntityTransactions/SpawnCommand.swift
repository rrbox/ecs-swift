//
//  SpawnCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class SpawnCommand: EntityTransaction {
    let entity: Entity
    let entityRecord: EntityRecordRef

    init(id: Entity, entityRecord: EntityRecordRef) {
        self.entity = id
        self.entityRecord = entityRecord
    }

    override func runCommand(in world: World) {
        world.push(entity: self.entity, entityRecord: self.entityRecord)
    }
}
