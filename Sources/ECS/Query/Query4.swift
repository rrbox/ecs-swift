//
//  Query4.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

final public class Query4<C0: QueryTarget, C1: QueryTarget, C2: QueryTarget, C3: QueryTarget>: Chunk, SystemParameter {
    var components = [Entity: (Ref<C0>, Ref<C1>, Ref<C2>, Ref<C3>)]()
    
    public override init() {}
    
    public override func spawn(entity: Entity, entityRecord: EntityRecordRef) {
        guard let c0 = entityRecord.ref(C0.self),
              let c1 = entityRecord.ref(C1.self),
              let c2 = entityRecord.ref(C2.self),
              let c3 = entityRecord.ref(C3.self) else { return }
        self.components[entity] = (c0, c1, c2, c3)
    }
    
    public override func despawn(entity: Entity) {
        self.components.removeValue(forKey: entity)
    }
    
    override func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) {
        guard let c0 = entityRecord.ref(C0.self),
              let c1 = entityRecord.ref(C1.self),
              let c2 = entityRecord.ref(C2.self),
              let c3 = entityRecord.ref(C3.self) else {
            self.components.removeValue(forKey: entity)
            return
        }
        self.components[entity] = (c0, c1, c2, c3)
    }
    
    /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
    public func update(_ execute: (Entity, inout C0, inout C1, inout C2, inout C3) -> ()) {
        for (entity, _) in self.components {
            execute(entity, &self.components[entity]!.0.value, &self.components[entity]!.1.value, &self.components[entity]!.2.value, &self.components[entity]!.3.value)
        }
    }
    
    public func update(_ entity: Entity, _ execute: (inout C0, inout C1, inout C2, inout C3) -> ()) {
        guard let group = self.components[entity] else { return }
        execute(&group.0.value, &group.1.value, &group.2.value, &group.3.value)
    }
    
    public func components(forEntity entity: Entity) -> (C0, C1, C2, C3)? {
        guard let references = components[entity] else { return nil }
        return (references.0.value, references.1.value, references.2.value, references.3.value)
    }
    
    public static func register(to worldStorage: WorldStorageRef) {
        guard worldStorage.chunkStorage.chunk(ofType: Self.self) == nil else {
            return
        }
        
        let queryRegistory = Self()
        
        worldStorage.chunkStorage.addChunk(queryRegistory)
        
    }
    
    public static func getParameter(from worldStorage: WorldStorageRef) -> Self? {
        worldStorage.chunkStorage.chunk(ofType: Self.self)
    }
    
}
