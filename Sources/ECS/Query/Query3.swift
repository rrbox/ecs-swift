//
//  Query3.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

final public class Query3<C0: Component, C1: Component, C2: Component>: Chunk, SystemParameter {
    var components = [Entity: (ComponentRef<C0>, ComponentRef<C1>, ComponentRef<C2>)]()
    
    override func spawn(entity: Entity, entityRecord: EntityRecord) {
        guard let c0 = entityRecord.component(ofType: ComponentRef<C0>.self),
              let c1 = entityRecord.component(ofType: ComponentRef<C1>.self),
              let c2 = entityRecord.component(ofType: ComponentRef<C2>.self) else { return }
        self.components[entity] = (c0, c1, c2)
    }
    
    override func despawn(entity: Entity) {
        self.components.removeValue(forKey: entity)
    }
    
    /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
    public func update(_ execute: (Entity, inout C0, inout C1, inout C2) -> ()) {
        for (entity, _) in self.components {
            execute(entity, &self.components[entity]!.0.value, &self.components[entity]!.1.value, &self.components[entity]!.2.value)
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
