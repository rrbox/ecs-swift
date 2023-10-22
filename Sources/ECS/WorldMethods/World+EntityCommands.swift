//
//  World+EntityCommands.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

extension World {
    /// Entity に Component を追加します.
    func addComponent<ComponentType: Component>(_ component: ComponentType, forEntity entity: Entity) {
        let archetype = self.entityRecord(forEntity: entity)!
        if let componentRef = archetype.component(ofType: ComponentRef<ComponentType>.self) {
            componentRef.value = component
        }
        archetype.addComponent(ComponentRef(component: component))
        self.worldBuffer.chunkBuffer.applyCurrentState(archetype, forEntity: entity)
    }
    
    /// Entity から Component を削除します.
    func removeComponent<ComponentType: Component>(ofType type: ComponentType.Type, fromEntity entity: Entity) {
        let archetype = self.entityRecord(forEntity: entity)!
        archetype.removeComponent(ofType: ComponentRef<ComponentType>.self)
        self.worldBuffer.chunkBuffer.applyCurrentState(archetype, forEntity: entity)
    }
}

