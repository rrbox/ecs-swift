//
//  World.swift
//  
//
//  Created by rrbox on 2023/08/06.
//

final public class World {
    var entities: [Entity: Archetype]
    public let worldBuffer: WorldBuffer
    
    init(entities: [Entity: Archetype], worldBuffer: WorldBuffer) {
        self.entities = entities
        self.worldBuffer = worldBuffer
    }
    
}
