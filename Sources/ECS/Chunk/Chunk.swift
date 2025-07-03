//
//  Chunk.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

public class Chunk: ChunkStorageElement {
    /// World に追加された
    func spawn(entityRecord: EntityRecordRef) {}
    func despawn(entity: Entity) {}

    func applyCurrentState(_ entityRecord: EntityRecordRef) {}
}
