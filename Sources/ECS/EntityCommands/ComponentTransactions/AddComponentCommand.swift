//
//  AddComponentCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class AddComponent<C: Component>: EntityCommand {
    let component: C
    
    init(entity: Entity, component: C) {
        self.component = component
        super.init(entity: entity)
    }
    
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        record.addComponent(component)
    }
    
}
