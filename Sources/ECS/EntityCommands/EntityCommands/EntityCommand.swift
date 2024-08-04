//
//  EntityCommand.swift
//  
//
//  Created by rrbox on 2023/08/18.
//

open class EntityCommand {
    public let entity: Entity
    public init(entity: Entity) {
        self.entity = entity
    }
    
    open func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        
    }
}
