//
//  Query5.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

final public class Query5<C0: Component, C1: Component, C2: Component, C3: Component, C4: Component>: Chunk, SystemParameter {
    var components = [Entity: (ComponentRef<C0>, ComponentRef<C1>, ComponentRef<C2>, ComponentRef<C3>, ComponentRef<C4>)]()
    
    override func spawn(entity: Entity, entityRecord: EntityRecord) {
        guard let c0 = entityRecord.component(ofType: ComponentRef<C0>.self),
              let c1 = entityRecord.component(ofType: ComponentRef<C1>.self),
              let c2 = entityRecord.component(ofType: ComponentRef<C2>.self),
              let c3 = entityRecord.component(ofType: ComponentRef<C3>.self),
              let c4 = entityRecord.component(ofType: ComponentRef<C4>.self) else { return }
        self.components[entity] = (c0, c1, c2, c3, c4)
    }
    
    override func despawn(entity: Entity) {
        self.components.removeValue(forKey: entity)
    }
    
    override func applyCurrentState(_ entityRecord: EntityRecord, forEntity entity: Entity) {
        guard let c0 = entityRecord.component(ofType: ComponentRef<C0>.self),
              let c1 = entityRecord.component(ofType: ComponentRef<C1>.self),
              let c2 = entityRecord.component(ofType: ComponentRef<C2>.self),
              let c3 = entityRecord.component(ofType: ComponentRef<C3>.self),
              let c4 = entityRecord.component(ofType: ComponentRef<C4>.self) else {
            self.components.removeValue(forKey: entity)
            return
        }
        self.components[entity] = (c0, c1, c2, c3, c4)
    }
    
    /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
    public func update(_ execute: (Entity, inout C0, inout C1, inout C2, inout C3, inout C4) -> ()) {
        for (entity, _) in self.components {
            execute(entity, &self.components[entity]!.0.value, &self.components[entity]!.1.value, &self.components[entity]!.2.value, &self.components[entity]!.3.value, &self.components[entity]!.4.value)
        }
    }
    
    public func update(_ entity: Entity, _ execute: (inout C0, inout C1, inout C2, inout C3, inout C4) -> ()) {
        guard let group = self.components[entity] else { return }
        execute(&group.0.value, &group.1.value, &group.2.value, &group.3.value, &group.4.value)
    }
    
    public func components(forEntity entity: Entity) -> (C0, C1, C2, C3, C4)? {
        guard let references = components[entity] else { return nil }
        return (references.0.value, references.1.value, references.2.value, references.3.value, references.4.value)
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
