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
    public let worldBuffer: BufferRef
    
    init(entities: [Entity: EntityRecordRef], worldBuffer: BufferRef) {
        self.entities = Entities(sequence: entities)
        self.worldBuffer = worldBuffer
    }
    
}


