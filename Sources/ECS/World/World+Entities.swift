//
//  World+Entities.swift
//  
//
//  Created by rrbox on 2023/08/18.
//

public extension World {
    func insert(entityRecord: EntityRecordRef) {
        self.entities.insert(entityRecord, withEntity: entityRecord.entity)
    }

    func remove(entity: Entity) {
        guard self.entities.contains(entity) else { return }
        self.entities.pop(entity: entity)
    }

    func entityRecord(forEntity entity: Entity) -> EntityRecordRef? {
        self.entities.value(forEntity: entity)
    }

}
