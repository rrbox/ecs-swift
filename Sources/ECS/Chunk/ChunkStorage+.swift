//
//  ChunkStorage+.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension AnyMap<ChunkStorage> {

}

extension ChunkStorageRef {

    // MARK: - public
    
    /// World 内の特定の entity を更新します
    /// - Parameter entityRecord: entity の components 構成クラス
    public func pushUpdated(entityRecord: EntityRecordRef) {
        storage.valueRef(ofType: ChunkEntityInterface.self)!
            .body
            .pushUpdated(entityRecord: entityRecord)
    }

    // MARK: - internal

    func chunk<ChunkType: Chunk>(ofType type: ChunkType.Type) -> ChunkType? {
        storage.valueRef(ofType: ChunkType.self)?.body
    }

    func addChunk<ChunkType: Chunk>(_ chunk: ChunkType) {
        storage.push(chunk)
        storage.valueRef(ofType: ChunkEntityInterface.self)!
            .body
            .add(chunk: chunk)
    }

    /// Chunk を登録し, すでに生存している entity をその Chunk にバックフィルします.
    ///
    /// 最初の spawn より後に登録された Query でも既存 entity を認識できるようにするための経路です.
    /// `entityRecords` には登録時点で生存している全 entity の record を渡します.
    func addChunk<ChunkType: Chunk>(_ chunk: ChunkType, backfilling entityRecords: [EntityRecordRef]) {
        self.addChunk(chunk)
        for entityRecord in entityRecords {
            chunk.applyCurrentState(entityRecord)
        }
    }

    func pushSpawned(entityRecord: EntityRecordRef) {
        storage.valueRef(ofType: ChunkEntityInterface.self)!
            .body
            .pushSpawned(entityRecord: entityRecord)
    }

    // MARK: - life cycle

    func setUpChunkBuffer() {
        storage.push(ChunkEntityInterface())
    }

    func applySpawnedEntityQueue() {
        storage.valueRef(ofType: ChunkEntityInterface.self)!
            .body
            .applySpawnedEntityQueue()
    }

    func applyUpdatedEntityQueue() {
        storage.valueRef(ofType: ChunkEntityInterface.self)!
            .body
            .applyUpdatedEntityQueue()
    }

    func despawn(entity: Entity) {
        storage.valueRef(ofType: ChunkEntityInterface.self)!
            .body
            .despawn(entity: entity)
    }

}
