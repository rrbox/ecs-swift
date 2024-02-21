//
//  AddComponentCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class AddComponent<C: Component>: ComponentTransaction {
    let entity: Entity
    let component: C
    
    init(entity: Entity, component: C) {
        self.entity = entity
        self.component = component
    }
    
    override func runCommand(in world: World) {
        world.addComponent(self.component, forEntity: self.entity)
    }
}
