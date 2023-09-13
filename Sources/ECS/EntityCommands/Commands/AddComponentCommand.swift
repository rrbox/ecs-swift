//
//  AddComponentCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class AddComponent<ComponentType: Component>: EntityCommand {
    let componnet: ComponentType
    
    init(entity: Entity, componnet: ComponentType) {
        self.componnet = componnet
        super.init(entity: entity)
    }
    
    override func runCommand(in world: World) {
        world.addComponent(self.componnet, forEntity: self.entity)
    }
}
