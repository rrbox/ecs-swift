//
//  Query2.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

final public class Query2<C0: QueryTarget, C1: QueryTarget>: Chunk, SystemParameter {
    var components = SparseSet<(Ref<C0>, Ref<C1>)>(sparse: [], dense: [], data: [])
    
    public override init() {}
    
    public func allocate() {
        self.components.allocate()
    }
    
    public func insert(entity: Entity, entityRecord: EntityRecordRef) {
        guard let c0 = entityRecord.ref(C0.self),
              let c1 = entityRecord.ref(C1.self) else { return }
        self.components.insert((c0, c1), withEntity: entity)
    }
    
    public override func spawn(entity: Entity, entityRecord: EntityRecordRef) {
        if entity.generation == 0 {
            self.components.allocate()
        }
        self.insert(entity: entity, entityRecord: entityRecord)
    }
    
    public override func despawn(entity: Entity) {
        guard self.components.contains(entity) else { return }
        self.components.pop(entity: entity)
    }
    
    override func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) {
        guard let c0 = entityRecord.ref(C0.self),
              let c1 = entityRecord.ref(C1.self) else {
            self.despawn(entity: entity)
            return
        }
        self.components.insert((c0, c1), withEntity: entity)
        
    }
    
    /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
    public func update(_ f: (inout C0, inout C1) -> ()) {
        for d in self.components.data {
            f(&d.0.value, &d.1.value)
        }
    }
    
    public func update(_ entity: Entity, _ f: (inout C0, inout C1) -> ()) {
        guard let ref = self.components.value(forEntity: entity) else { return }
        f(&ref.0.value, &ref.1.value)
    }
    
    public func components(forEntity entity: Entity) -> (C0, C1)? {
        guard let references = components.value(forEntity: entity) else { return nil }
        return (references.0.value, references.1.value)
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
