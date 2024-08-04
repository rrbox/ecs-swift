//
//  RemoveComponentCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class RemoveComponent<C: Component>: EntityCommand {
    init(entity: Entity, componentType type: C.Type) {
        super.init(entity: entity)
    }
    
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        record.removeComponent(ofType: C.self)
    }
    
}
