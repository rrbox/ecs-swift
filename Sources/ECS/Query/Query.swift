//
//  Query.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

final public class Query<C: QueryTarget>: Chunk, SystemParameter {
    var components = SparseSet<Ref<C>>(sparse: [], dense: [], data: [])
    
    public override init() {}
    
    public func allocate() {
        self.components.allocate()
    }
    
    public func insert(entity: Entity, entityRecord: EntityRecordRef) {
        guard let componentRef = entityRecord.ref(C.self) else { return }
        self.components.insert(componentRef, withEntity: entity)
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
        guard let componentRef = entityRecord.ref(C.self) else {
            self.despawn(entity: entity)
            return
        }
        self.components.insert(componentRef, withEntity: entity)
    }
    
    /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
    public func update(_ f: (inout C) -> ()) {
        for ref in self.components.data {
            f(&ref.value)
        }
    }
    
    public func update(_ entity: Entity, _ f: (inout C) -> ()) {
        guard let ref = self.components.value(forEntity: entity) else { return }
        f(&ref.value)
    }
    
    public func components(forEntity entity: Entity) -> C? {
        self.components.value(forEntity: entity)?.value
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
