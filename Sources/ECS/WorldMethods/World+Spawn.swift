//
//  World+Spawn.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

@available(*, deprecated)
public struct DidSpawnEvent: CommandsEventProtocol {
    public let spawnedEntity: Entity
}

@available(*, deprecated)
public struct WillDespawnEvent: CommandsEventProtocol {
    public let despawnedEntity: Entity
}

public extension Schedule {
    @available(*, deprecated)
    static let didSpawn: Schedule = .onCommandsEvent(ofType: DidSpawnEvent.self)
    @available(*, deprecated)
    static let willDespawn: Schedule = .onCommandsEvent(ofType: WillDespawnEvent.self)
}

extension World {
    /// Entity を登録します.
    ///
    /// ``Commands/spawn()`` が実行された後, フレームが終了するタイミングでこの関数が実行されます.
    /// entity へのコンポーネントの登録などは, push の後に行われます.
    func push(entityRecord: EntityRecordRef) {
        if entityRecord.entity.generation == 0 {
            self.entities.allocate()
        }

        self.insert(entityRecord: entityRecord)
        self.worldStorage
            .chunkStorageRef
            .pushSpawned(entityRecord: entityRecord)
        self.worldStorage
            .eventStorage
            .commandsEventWriter(eventOfType: DidSpawnEvent.self)!
            .send(value: DidSpawnEvent(spawnedEntity: entityRecord.entity))
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
            .commandsEventWriter(eventOfType: WillDespawnEvent.self)!
            .send(value: WillDespawnEvent(despawnedEntity: entity))
    }
}
