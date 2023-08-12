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
        guard let componentRef = world.entities[self.entity]?
            .component(ofType: ComponentRef<ComponentType>.self) else {
            world.entities[self.entity]?.addComponent(ComponentRef(component: self.componnet))
            return
        }
        componentRef.value = self.componnet
    }
}
