//
//  ChunkStorage+.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension AnyMap<ChunkStorage> {

    // MARK: - public
    
    /// World 内の特定の entity を更新します
    /// - Parameter entityRecord: entity の components 構成クラス
    public func pushUpdated(entityRecord: EntityRecordRef) {
        valueRef(ofType: ChunkEntityInterface.self)!.body.pushUpdated(entityRecord: entityRecord)
    }

    // MARK: - internal

    mutating func addChunk<ChunkType: Chunk>(_ chunk: ChunkType) {
        push(chunk)
        valueRef(ofType: ChunkEntityInterface.self)!.body.add(chunk: chunk)
    }

    func pushSpawned(entityRecord: EntityRecordRef) {
        valueRef(ofType: ChunkEntityInterface.self)!.body.pushSpawned(entityRecord: entityRecord)
    }

    // MARK: - life cycle

    mutating func setUpChunkBuffer() {
        push(ChunkEntityInterface())
    }

    func applySpawnedEntityQueue() {
        valueRef(ofType: ChunkEntityInterface.self)!.body.applySpawnedEntityQueue()
    }

    func applyUpdatedEntityQueue() {
        valueRef(ofType: ChunkEntityInterface.self)!.body.applyUpdatedEntityQueue()
    }

    func despawn(entity: Entity) {
        valueRef(ofType: ChunkEntityInterface.self)!.body.despawn(entity: entity)
    }

}
