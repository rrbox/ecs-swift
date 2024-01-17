//
//  Chunk.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

public protocol Chunk: WorldStorageElement {
    func spawn(entity: Entity, entityRecord: EntityRecordRef) async
    func despawn(entity: Entity) async
    func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) async
}
