//
//  Chunk.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

public class Chunk {
    func spawn(entity: Entity, entityRecord: EntityRecordRef) {}
    func despawn(entity: Entity) {}
    func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) {}
}
