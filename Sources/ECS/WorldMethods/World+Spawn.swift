//
//  World+Spawn.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

public struct DidSpawnEvent: CommandsEventProtocol {
    public let spawnedEntity: Entity
}

public struct WillDespawnEvent: CommandsEventProtocol {
    public let despawnedEntity: Entity
}

public extension Schedule {
    static let didSpawn: Schedule = .onCommandsEvent(ofType: DidSpawnEvent.self)
    static let willDespawn: Schedule = .onCommandsEvent(ofType: WillDespawnEvent.self)
}

extension World {
    /// Entity を登録します.
    ///
    /// ``Commands/spawn()`` が実行された後, フレームが終了するタイミングでこの関数が実行されます.
    /// entity へのコンポーネントの登録などは, push の後に行われます.
    func push(entity: Entity, entityRecord: EntityRecordRef) {
        entityRecord.map.body[ObjectIdentifier(Entity.self)] = ImmutableRef(value: entity)
        
        self.insert(entity: entity, entityRecord: entityRecord)
        self.worldStorage
            .chunkStorage
            .push(entity: entity, entityRecord: entityRecord)
        
        self.worldStorage
            .eventStorage
            .commandsEventWriter(eventOfType: DidSpawnEvent.self)!
            .send(value: DidSpawnEvent(spawnedEntity: entity))
    }
    
    /// Entity を削除します.
    ///
    /// ``Commands/despawn()`` が実行された後, フレームが終了するタイミングでこの関数が実行されます.
    func despawn(entity: Entity) {
        self.remove(entity: entity)
        self.worldStorage
            .chunkStorage
            .despawn(entity: entity)
        
        self.worldStorage
            .eventStorage
            .commandsEventWriter(eventOfType: WillDespawnEvent.self)!
            .send(value: WillDespawnEvent(despawnedEntity: entity))
    }
}
