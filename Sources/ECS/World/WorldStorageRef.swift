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
    /// Chunk (Query) 登録時に既存 entity をバックフィルする経路 (`register(to:)`) からは
    /// `WorldStorageRef` しか辿れないため, `World` ではなく storage 側でこの台帳を保持します.
    var entities = SparseSet<EntityRecordRef>(sparse: [], dense: [], data: [])

    // MARK: - public

    public let chunkStorageRef = ChunkStorageRef()
    public var additionalStorage = AnyMap<AdditionalStorage>()
}
