//
//  World+Entities.swift
//  
//
//  Created by rrbox on 2023/08/18.
//

public extension World {
    func insert(entity: Entity, entityRecord: EntityRecord) {
        self.entities.sequence[entity] = entityRecord
    }
    
    func remove(entity: Entity) {
        self.entities.sequence.removeValue(forKey: entity)
    }
    
    func entityRecord(forEntity entity: Entity) -> EntityRecord? {
        self.entities.sequence[entity]
    }

}
