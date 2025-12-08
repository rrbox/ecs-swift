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
    func push(entityRecord: EntityRecordRef) {
        if entityRecord.entity.generation == 0 {
            if FeatureFlags.isEnabled(.contiguousArrayStorage) {
                self.contiguousEntities.allocate()
            } else {
                self.defaultEntities.allocate()
            }
        }

        self.insert(entityRecord: entityRecord)
        self.worldStorage
            .chunkStorageRef
            .pushSpawned(entityRecord: entityRecord)
        self.sendEvent(Spawned(spawnedEntity: entityRecord.entity))
    }

    /// Entity を削除します.
    ///
    /// ``Commands/despawn()`` が実行された後, フレームが終了するタイミングでこの関数が実行されます.
    func despawn(entity: Entity) {
        self.remove(entity: entity)
        self.worldStorage
            .chunkStorageRef
            .despawn(entity: entity)
        self.worldStorage
            .eventStorage
            .removedEventReceiver()?
            .pushDespawned(entity)
    }
}
