//
//  Commands+EntityCommands.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

public extension Commands {
    /// Entity を取得して変更を加えます
    func entity(_ entity: Entity) -> EntityCommands? {
        return EntityCommands(entity: entity, commands: self)
    }
    
    /// Entity を追加して変更を加えます.
//    func spawn() -> EntityCommands {
//        let entity = Entity()
//        self.commandQueue.append(SpawnCommand(id: entity, entityRecord: EntityRecordRef()))
//        return EntityCommands(entity: entity, commands: self)
//    }
    
    /// Entity を追加して変更を加えます.
    func spawn() -> EntityCommands {
        let entity = self.generator.generate()
        let record = EntityRecordRef()
        
        record.map.body[ObjectIdentifier(Entity.self)] = ImmutableRef(value: entity)
        
        self.generator.pop()
        
        self.entityTransactions.append(SpawnCommand(id: entity, entityRecord: record))
        
        return EntityCommands(entity: entity, commands: self)
    }
    
    /// Entity を削除します.
    func despawn(entity: Entity) {
        self.generator.stack(entity: Entity(slot: entity.slot, generation: entity.generation+1))
        self.entityTransactions.append(DespawnCommand(entity: entity))
    }
}
