//
//  RemoveComponentCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class RemoveComponent<ComponentType: Component>: Command {
    let entity: Entity
    
    init(entity: Entity, componentType type: ComponentType.Type) {
        self.entity = entity
    }
    
    override func runCommand(in world: World) {
        world.entities[self.entity]?.removeComponent(ofType: ComponentRef<ComponentType>.self)
    }
}
