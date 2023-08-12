//
//  EntityCommands.swift
//  
//
//  Created by rrbox on 2023/08/09.
//

final public class EntityCommands {
    public let entity: Entity
    let commands: Commands
    
    init(entity: Entity, commands: Commands) {
        self.entity = entity
        self.commands = commands
    }
    
    public func id() -> Entity {
        self.entity
    }
    
}
