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

    /// 検証用の実行時オプションです。World の初期化時に確定し、以後変更されません(要件 4-4)。
    let experimentalOptions: ExperimentalWorldOptions

    /// Archetype ベースの entity ストレージです。
    ///
    /// `experimentalOptions` に ``ExperimentalWorldOptions/archetypeStorage`` が
    /// 含まれる場合のみ生成されます。OFF の場合は nil となり、旧経路からの
    /// 誤参照をクラッシュとして検出できるようにします(設計方針)。
    let archetypeStorageRef: ArchetypeStorageRef?

    init(experimentalOptions: ExperimentalWorldOptions = []) {
        self.experimentalOptions = experimentalOptions
        self.archetypeStorageRef = experimentalOptions.contains(.archetypeStorage)
            ? ArchetypeStorageRef()
            : nil
    }

    // MARK: - public

    public let chunkStorageRef = ChunkStorageRef()
    public var additionalStorage = AnyMap<AdditionalStorage>()
}
