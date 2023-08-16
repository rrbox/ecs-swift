//
//  AddChunk.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension ChunkBuffer {
    func setUpChunkBuffer() {
        self.buffer.addComponent(ChunkEntityInterface())
    }
    
    func addChunk<ChunkType: Chunk>(_ chunk: ChunkType) {
        self.buffer.addComponent(ChunkRegistry(chunk: chunk))
        self.buffer.component(ofType: ChunkEntityInterface.self)!.add(chunk: chunk)
    }
    
    func push(entity: Entity, entityRecord: EntityRecord) {
        self.buffer.component(ofType: ChunkEntityInterface.self)!.push(entity: entity, entityRecord: entityRecord)
    }
    
    func applyEntityQueue() {
        self.buffer.component(ofType: ChunkEntityInterface.self)!.applyEntityQueue()
    }
    
    func despawn(entity: Entity) {
        self.buffer.component(ofType: ChunkEntityInterface.self)!.despawn(entity: entity)
    }
    
    // entity を最新の状態に更新します.
    func applyCurrentState(_ entityRecord: EntityRecord, forEntity entity: Entity) {
        self.buffer.component(ofType: ChunkEntityInterface.self)!.applyCurrentState(entityRecord, forEntity: entity)
    }
    
}
