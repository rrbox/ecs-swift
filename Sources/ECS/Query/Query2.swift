//
//  Query2.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public actor Query2<C0: Component, C1: Component>: Chunk, SystemParameter {
    var components = [Entity: (ComponentRef<C0>, ComponentRef<C1>)]()
    var executes: [(Entity, inout C0, inout C1) -> ()] = []
    
    public init() {}
    
    public func spawn(entity: Entity, entityRecord: EntityRecordRef) {
        guard let c0 = entityRecord.componentRef(C0.self),
              let c1 = entityRecord.componentRef(C1.self) else { return }
        self.components[entity] = (c0, c1)
    }
    
    public func despawn(entity: Entity) {
        self.components.removeValue(forKey: entity)
    }
    
    public func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) {
        guard let c0 = entityRecord.componentRef(C0.self),
              let c1 = entityRecord.componentRef(C1.self) else {
            self.components.removeValue(forKey: entity)
            return
        }
        self.components[entity] = (c0, c1)
        
    }
    
    /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
    public func update(_ execute: (Entity, inout C0, inout C1) -> ()) {
        for (entity, _) in self.components {
            execute(entity, &self.components[entity]!.0.value, &self.components[entity]!.1.value)
        }
    }
    
    public func update(_ entity: Entity, _ execute: (inout C0, inout C1) -> ()) {
        guard let group = self.components[entity] else { return }
        execute(&group.0.value, &group.1.value)
    }
    
    public func components(forEntity entity: Entity) -> (C0, C1)? {
        guard let references = components[entity] else { return nil }
        return (references.0.value, references.1.value)
    }

    
    public static func register(to worldStorage: WorldStorageRef) async {
        guard worldStorage.chunkStorage.chunk(ofType: Self.self) == nil else {
            return
        }
        
        let queryRegistory = Self()
        
        await worldStorage.chunkStorage.addChunk(queryRegistory)
        
    }
    
    public static func getParameter(from worldStorage: WorldStorageRef) -> Self? {
        worldStorage.chunkStorage.chunk(ofType: Self.self)
    }
    
}
