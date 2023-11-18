//
//  AddChunk.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension ChunkBuffer {
    func setUpChunkBuffer() {
        self.buffer.map.push(ChunkEntityInterface())
    }
    
    func addChunk<ChunkType: Chunk>(_ chunk: ChunkType) {
        self.buffer.map.push(ChunkRegistry(chunk: chunk))
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.add(chunk: chunk)
    }
    
    func push(entity: Entity, entityRecord: EntityRecordRef) {
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.push(entity: entity, entityRecord: entityRecord)
    }
    
    func applyEntityQueue() {
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.applyEntityQueue()
    }
    
    func despawn(entity: Entity) {
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.despawn(entity: entity)
    }
    
    // entity を最新の状態に更新します.
    func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) {
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.applyCurrentState(entityRecord, forEntity: entity)
    }
    
}
