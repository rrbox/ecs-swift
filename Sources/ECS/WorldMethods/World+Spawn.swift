//
//  World+Spawn.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

public struct Spawned: EventProtocol {
    public let spawnedEntity: Entity
}

extension World {
    /// Entity を登録します.
    ///
    /// ``Commands/spawn()`` が実行された後, フレームが終了するタイミングでこの関数が実行されます.
    /// entity へのコンポーネントの登録などは, push の後に行われます.
    ///
    /// archetype storage が ON の場合は staging queue へ積むのみで, Archetype への
    /// 実際の挿入は applyCommandsPhase で行われます(design.md World 分岐点2)。
    /// entity table への登録と ``Spawned`` イベントの発行は新旧共通です(要件 1-6)。
    func push(entityRecord: EntityRecordRef) {
        self.insert(entityRecord: entityRecord)
        if let archetypeStorage = self.worldStorage.archetypeStorageRef {
            archetypeStorage.spawnStagingQueue.append(entityRecord)
        } else {
            self.worldStorage
                .chunkStorageRef
                .pushSpawned(entityRecord: entityRecord)
        }
        self.sendEvent(Spawned(spawnedEntity: entityRecord.entity))
    }

    /// Entity を削除します.
    ///
    /// ``Commands/despawn()`` が実行された後, フレームが終了するタイミングでこの関数が実行されます.
    ///
    /// archetype storage が ON の場合は所属 Archetype の行を swap-remove し,
    /// 穴を埋めた entity の所在(行番号)を補正します(design.md World 分岐点3)。
    /// archetype storage 層では未登録・世代不一致の entity は no-op です(要件 1-4)。
    /// なお entity table(``World/remove(entity:)``)側は従来どおり, slot が生存中の世代不一致に対して
    /// デバッグビルドで assertion が働きます(新旧共通の既存挙動)。
    /// entity table からの削除と Removed lifecycle への通知は新旧共通です(要件 1-7)。
    func despawn(entity: Entity) {
        self.remove(entity: entity)
        if let archetypeStorage = self.worldStorage.archetypeStorageRef {
            archetypeStorage.despawn(entity: entity)
        } else {
            self.worldStorage
                .chunkStorageRef
                .despawn(entity: entity)
        }
        self.worldStorage
            .eventStorage
            .removedEventReceiver()?
            .pushDespawned(entity)
    }
}
