//
//  World.swift
//  
//
//  Created by rrbox on 2023/08/06.
//

public struct Entities {
    var sequence: [Entity: EntityRecord]
    
    public mutating func insert(entity: Entity, entityRecord: EntityRecord) {
        self.sequence[entity] = entityRecord
    }
    
    public mutating func remove(entity: Entity) {
        self.sequence.removeValue(forKey: entity)
    }
    
    public mutating func entityRecord(forEntity entity: Entity) -> EntityRecord? {
        self.sequence[entity]
    }
}

final public class World {
    var entities: Entities
    public let worldBuffer: WorldBuffer
    
    init(entities: [Entity: EntityRecord], worldBuffer: WorldBuffer) {
        self.entities = Entities(sequence: entities)
        self.worldBuffer = worldBuffer
    }
    
}
