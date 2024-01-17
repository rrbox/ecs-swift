//
//  RemoveComponentCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class RemoveComponent<ComponentType: Component>: EntityCommand {
    init(entity: Entity, componentType type: ComponentType.Type) {
        super.init(entity: entity)
    }
    
    override func runCommand(in world: World) async {
        await world.removeComponent(ofType: ComponentType.self, fromEntity: self.entity)
    }
}
