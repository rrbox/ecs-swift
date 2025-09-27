//
//  World+Entities.swift
//  
//
//  Created by rrbox on 2023/08/18.
//

public extension World {
    func insert(entityRecord: EntityRecordRef) {
        if FeatureFlags.isEnabled(.contiguousArrayStorage) {
            self.contiguousEntities.insert(entityRecord, withEntity: entityRecord.entity)
        } else {
            self.defaultEntities.insert(entityRecord, withEntity: entityRecord.entity)
        }
    }

    func remove(entity: Entity) {
        if FeatureFlags.isEnabled(.contiguousArrayStorage) {
            guard self.contiguousEntities.contains(entity) else { return }
            self.contiguousEntities.pop(entity: entity)
        } else {
            guard self.defaultEntities.contains(entity) else { return }
            self.defaultEntities.pop(entity: entity)
        }
    }

    func entityRecord(forEntity entity: Entity) -> EntityRecordRef? {
        if FeatureFlags.isEnabled(.contiguousArrayStorage) {
            self.contiguousEntities.value(forEntity: entity)
        } else {
            self.defaultEntities.value(forEntity: entity)
        }
    }

}
