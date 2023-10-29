//
//  World.swift
//  
//
//  Created by rrbox on 2023/08/06.
//

public struct Entities {
    var sequence: [Entity: EntityRecordRef]
}

final public class World {
    var entities: Entities
    public let worldStorage: WorldStorageRef
    
    init(entities: [Entity: EntityRecordRef], worldStorage: WorldStorageRef) {
        self.entities = Entities(sequence: entities)
        self.worldStorage = worldStorage
    }
    
}
