//
//  AddComponentCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class AddComponent<ComponentType: Component>: Command {
    let entity: Entity
    let componnet: ComponentType
    
    init(entity: Entity, componnet: ComponentType) {
        self.entity = entity
        self.componnet = componnet
    }
    
    override func runCommand(in world: World) {
        world.addComponent(self.componnet, forEntity: self.entity)
    }
}
