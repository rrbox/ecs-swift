//
//  SpawnCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class SpawnCommand: EntityTransaction {
    let entityRecord: EntityRecordRef

    init(entityRecord: EntityRecordRef) {
        self.entityRecord = entityRecord
    }

    override func runCommand(in world: World) {
        world.push(entityRecord: self.entityRecord)
    }
}
