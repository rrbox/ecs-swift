//
//  Query.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

final public class Query<ComponentType: Component>: Chunk, SystemParameter {
    var components = [Entity: ComponentRef<ComponentType>]()
    
    public override init() {}
    
    public override func spawn(entity: Entity, entityRecord: EntityRecordRef) {
        guard let componentRef = entityRecord.componentRef(ComponentType.self) else { return }
        self.components[entity] = componentRef
    }
    
    public override func despawn(entity: Entity) {
        self.components.removeValue(forKey: entity)
    }
    
    override func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) {
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
    
    public static func register(to worldBuffer: BufferRef) {
        guard worldBuffer.chunkBuffer.chunk(ofType: Self.self) == nil else {
            return
        }
        
        let queryRegistory = Self()
        
        worldBuffer.chunkBuffer.addChunk(queryRegistory)
        
    }
    
    public static func getParameter(from worldBuffer: BufferRef) -> Self? {
        worldBuffer.chunkBuffer.chunk(ofType: Self.self)
    }
    
}
