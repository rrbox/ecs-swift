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

    // MARK: - public

    public let chunkStorageRef = ChunkStorageRef()
    public var additionalStorage = AnyMap<AdditionalStorage>()
}
