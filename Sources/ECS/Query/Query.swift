//
//  Query.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

final public class Query<ComponentType: Component>: Chunk, SystemParameter {
    var components = [Entity: ComponentRef<ComponentType>]()
    
    override func spawn(entity: Entity, entityRecord: EntityRecord) {
        guard let componentRef = entityRecord.component(ofType: ComponentRef<ComponentType>.self) else { return }
        self.components[entity] = componentRef
    }
    
    override func despawn(entity: Entity) {
        self.components.removeValue(forKey: entity)
    }
    
    /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
    public func update(_ execute: (Entity, inout ComponentType) -> ()) {
        for (entity, _) in self.components {
            execute(entity, &self.components[entity]!.value)
        }
    }
    
    public static func register(to worldBuffer: WorldBuffer) {
        guard worldBuffer.chunkBuffer.chunk(ofType: Self.self) == nil else {
            return
        }
        
        let queryRegistory = Self()
        
        worldBuffer.chunkBuffer.addChunk(queryRegistory)
        
    }
    
    public static func getParameter(from worldBuffer: WorldBuffer) -> Self? {
        worldBuffer.chunkBuffer.chunk(ofType: Self.self)
    }
    
}
