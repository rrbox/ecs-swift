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
    func spawn() -> EntityCommands {
        let entity = Entity()
        self.commandQueue.append(SpawnCommand(id: entity, entityRecord: EntityRecord()))
        return EntityCommands(entity: entity, commands: self)
    }
    
    /// Entity を削除します.
    func despawn(entity: Entity) {
        self.commandQueue.append(DespawnCommand(entity: entity))
    }
}
