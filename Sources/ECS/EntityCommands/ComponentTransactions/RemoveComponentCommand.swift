//
//  RemoveComponentCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class RemoveComponent<C: Component>: ComponentTransaction {
    let entity: Entity
    init(entity: Entity, componentType type: C.Type) {
        self.entity = entity
    }
    
    override func runCommand(in world: World) {
        world.removeComponent(ofType: C.self, fromEntity: self.entity)
    }
}
