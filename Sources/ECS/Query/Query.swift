//
//  Query.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public actor Query<ComponentType: Component>: Chunk, SystemParameter {
    var components = [Entity: ComponentRef<ComponentType>]()
    
    public init() {}
    
    public func spawn(entity: Entity, entityRecord: EntityRecordRef) async {
        guard let componentRef = entityRecord.componentRef(ComponentType.self) else { return }
        self.components[entity] = componentRef
    }
    
    public func despawn(entity: Entity) async {
        self.components.removeValue(forKey: entity)
    }
    
    public func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) {
        guard let componentRef = entityRecord.componentRef(ComponentType.self) else {
            self.components.removeValue(forKey: entity)
            return
        }
        self.components[entity] = componentRef
    }
    
    /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
    public func update(_ execute: (Entity, inout ComponentType) -> ()) {
        for (entity, _) in self.components {
            execute(entity, &self.components[entity]!.value)
        }
    }
    
    public func update(_ entity: Entity, _ execute: (inout ComponentType) -> ()) {
        guard let componentRef = self.components[entity] else { return }
        execute(&componentRef.value)
    }
    
    public func components(forEntity entity: Entity) -> ComponentType? {
        self.components[entity]?.value
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
