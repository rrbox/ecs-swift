//
//  ChunkStorage+.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension AnyMap<ChunkStorage> {
    mutating func setUpChunkBuffer() {
        push(ChunkEntityInterface())
    }

    mutating func addChunk<ChunkType: Chunk>(_ chunk: ChunkType) {
        push(chunk)
        valueRef(ofType: ChunkEntityInterface.self)!.body.add(chunk: chunk)
    }

    func pushSpawned(entityRecord: EntityRecordRef) {
        valueRef(ofType: ChunkEntityInterface.self)!.body.pushSpawned(entityRecord: entityRecord)
    }

    func applySpawnedEntityQueue() {
        valueRef(ofType: ChunkEntityInterface.self)!.body.applySpawnedEntityQueue()
    }

    public func pushUpdated(entityRecord: EntityRecordRef) {
        valueRef(ofType: ChunkEntityInterface.self)!.body.pushUpdated(entityRecord: entityRecord)
    }

    func applyUpdatedEntityQueue() {
        valueRef(ofType: ChunkEntityInterface.self)!.body.applyUpdatedEntityQueue()
    }

    func despawn(entity: Entity) {
        valueRef(ofType: ChunkEntityInterface.self)!.body.despawn(entity: entity)
    }

}
