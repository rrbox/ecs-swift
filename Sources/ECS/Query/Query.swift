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

    public func insert(entityRecord: EntityRecordRef) {
        guard let componentRef = entityRecord.ref(C.self) else { return }
        self.components.insert(componentRef, withEntity: entityRecord.entity)
    }

    public func remove(entity: Entity) {
        guard self.components.contains(entity) else { return }
        self.components.pop(entity: entity)
    }

    override func spawn(entityRecord: EntityRecordRef) {
        if entityRecord.entity.generation == 0 {
            self.components.allocate()
        }
        self.insert(entityRecord: entityRecord)
    }

    override func despawn(entity: Entity) {
        self.remove(entity: entity)
    }

    override func applyCurrentState(_ entityRecord: EntityRecordRef) {
        guard let componentRef = entityRecord.ref(C.self) else {
            self.despawn(entity: entityRecord.entity)
            return
        }
        guard !components.contains(entityRecord.entity) else { return }
        self.components.insert(
            componentRef,
            withEntity: entityRecord.entity
        )
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
        guard worldStorage.chunkStorageRef.chunk(ofType: Self.self) == nil else {
            return
        }

        let queryRegistory = Self()

        worldStorage.chunkStorageRef.addChunk(queryRegistory)

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> Self? {
        worldStorage.chunkStorageRef.chunk(ofType: Self.self)
    }

}
