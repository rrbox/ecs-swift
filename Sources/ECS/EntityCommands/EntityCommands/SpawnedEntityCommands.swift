//
//  SpawnedEntityCommands.swift
//  
//
//  Created by rrbox on 2024/02/18.
//

final public class SpawnedEntityCommands: EntityCommands {
    let record: EntityRecordRef
    
    init(entity: Entity, record: EntityRecordRef, commands: Commands) {
        self.record = record
        super.init(entity: entity, commands: commands)
    }
    
    @discardableResult public override func addComponent<C: Component>(_ component: C) -> SpawnedEntityCommands {
        self.record.addComponent(component)
        return self
    }
    
    @discardableResult public override func removeComponent<C: Component>(ofType type: C.Type) -> SpawnedEntityCommands {
        self.record.removeComponent(ofType: C.self)
        return self
    }
}
