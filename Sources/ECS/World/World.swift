//
//  World.swift
//  
//
//  Created by rrbox on 2023/08/06.
//

public struct Entities {
    var sequence: [Entity: EntityRecord]
}

final public class World {
    var entities: Entities
    public let worldBuffer: WorldBuffer
    
    init(entities: [Entity: EntityRecord], worldBuffer: WorldBuffer) {
        self.entities = Entities(sequence: entities)
        self.worldBuffer = worldBuffer
    }
    
}


