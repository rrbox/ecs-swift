//
//  FilteredQuery.swift
//  
//
//  Created by rrbox on 2023/09/17.
//

final public class Filtered<Q: QueryProtocol, F: Filter>: Chunk, SystemParameter {
    let query: Q = Q()

    override func spawn(entityRecord: EntityRecordRef) {
        if entityRecord.entity.generation == 0 {
            self.query.allocate()
        }
        guard F.condition(forEntityRecord: entityRecord) else { return }
        self.query.insert(entityRecord: entityRecord)
    }

    override func despawn(entity: Entity) {
        self.query.despawn(entity: entity)
    }

    public func update( _ f: Q.Update) {
        self.query.update(f)
    }

    public func update(_ entity: Entity, _ f: Q.Update) {
        self.query.update(entity, f)
    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> Filtered<Q, F>? {
        worldStorage.chunkStorage.chunk(ofType: Filtered<Q, F>.self)
    }

    public static func register(to worldStorage: WorldStorageRef) {
        guard worldStorage.chunkStorage.chunk(ofType: Self.self) == nil else {
            return
        }

        worldStorage.chunkStorage.addChunk(Filtered<Q, F>())
    }

    override func applyCurrentState(_ entityRecord: EntityRecordRef) {
        guard F.condition(forEntityRecord: entityRecord) else {
            self.query.despawn(entity: entityRecord.entity)
            return
        }
        self.query.applyCurrentState(entityRecord)
    }

}
