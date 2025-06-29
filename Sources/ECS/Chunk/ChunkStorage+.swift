//
//  ChunkStorage+.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension ChunkStorage {
    func setUpChunkBuffer() {
        self.buffer.map.push(ChunkEntityInterface())
    }

    func addChunk<ChunkType: Chunk>(_ chunk: ChunkType) {
        self.buffer.map.push(chunk)
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.add(chunk: chunk)
    }

    func pushSpawned(entityRecord: EntityRecordRef) {
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.pushSpawned(entityRecord: entityRecord)
    }

    func applySpawnedEntityQueue() {
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.applySpawnedEntityQueue()
    }

    public func pushUpdated(entityRecord: EntityRecordRef) {
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.pushUpdated(entityRecord: entityRecord)
    }

    func applyUpdatedEntityQueue() {
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.applyUpdatedEntityQueue()
    }

    func despawn(entity: Entity) {
        self.buffer.map.valueRef(ofType: ChunkEntityInterface.self)!.body.despawn(entity: entity)
    }

}
