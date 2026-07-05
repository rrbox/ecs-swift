//
//  WorldStorage.swift
//
//
//  Created by rrbox on 2023/08/07.
//

final public class WorldStorageRef {
    let commands = Commands()
    var eventStorage = AnyMap<EventStorage>()
    var resourceStorage = AnyMap<ResourceStorage>()
    var stateStorage = AnyMap<StateStorage>()
    var systemStorage = AnyMap<SystemStorage>()

    /// World 内で生存している全 entity の台帳.
    ///
    /// Chunk (Query) の登録時に既存 entity をバックフィルするため, `World` ではなく storage 側で保持します.
    var entities = SparseSet<EntityRecordRef>(sparse: [], dense: [], data: [])

    // MARK: - public

    public let chunkStorageRef = ChunkStorageRef()
    public var additionalStorage = AnyMap<AdditionalStorage>()

    /// Chunk を登録し, すでに生存している全 entity をその Chunk に反映 (バックフィル) します.
    ///
    /// これにより, 最初の spawn より後に登録された Query でも既存 entity を認識できます.
    func addChunk<ChunkType: Chunk>(_ chunk: ChunkType) {
        self.chunkStorageRef.addChunk(chunk)
        for entityRecord in self.entities.data {
            chunk.applyCurrentState(entityRecord)
        }
    }
}
