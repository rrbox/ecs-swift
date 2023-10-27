//
//  FilteredQuery.swift
//  
//
//  Created by rrbox on 2023/09/17.
//

final public class Filtered<Q: QueryProtocol, F: Filter>: Chunk, SystemParameter {
    public let query: Q = Q()
    
    override func spawn(entity: Entity, entityRecord: EntityRecordRef) {
        guard F.condition(forEntityRecord: entityRecord) else { return }
        self.query.spawn(entity: entity, entityRecord: entityRecord)
    }
    
    override func despawn(entity: Entity) {
        self.query.despawn(entity: entity)
    }
    
    public static func getParameter(from worldBuffer: BufferRef) -> Filtered<Q, F>? {
        worldBuffer.chunkStorage.chunk(ofType: Filtered<Q, F>.self)
    }
    
    public static func register(to worldBuffer: BufferRef) {
        guard worldBuffer.chunkStorage.chunk(ofType: Self.self) == nil else {
            return
        }
        
        worldBuffer.chunkStorage.addChunk(Filtered<Q, F>())
    }
    
}
