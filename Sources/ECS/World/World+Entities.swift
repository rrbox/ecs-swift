//
//  World+Entities.swift
//  
//
//  Created by rrbox on 2023/08/18.
//

public extension World {
    func insert(entity: Entity, entityRecord: EntityRecordRef) {
        self.entities.insert(entityRecord, withEntity: entity)
    }
    
    func remove(entity: Entity) {
        self.entities.pop(entity: entity)
    }
    
    func entityRecord(forEntity entity: Entity) -> EntityRecordRef? {
        self.entities.value(forEntity: entity)
    }

}
