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
        if let componentRef = archetype.ref(ComponentType.self) {
            componentRef.value = component
        }
        archetype.addComponent(component)
        self.worldStorage.chunkStorage.apply(archetype, forEntity: entity)
    }
    
    /// Entity から Component を削除します.
    func removeComponent<ComponentType: Component>(ofType type: ComponentType.Type, fromEntity entity: Entity) {
        guard let archetype = self.entityRecord(forEntity: entity) else { return }
        archetype.removeComponent(ofType: ComponentType.self)
        self.worldStorage.chunkStorage.apply(archetype, forEntity: entity)
    }
}

