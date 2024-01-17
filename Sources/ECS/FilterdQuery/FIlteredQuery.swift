//
//  FilteredQuery.swift
//  
//
//  Created by rrbox on 2023/09/17.
//

public actor Filtered<Q: QueryProtocol, F: Filter>: Chunk, SystemParameter {
    public let query: Q = Q()
    
    public func spawn(entity: Entity, entityRecord: EntityRecordRef) async {
        guard F.condition(forEntityRecord: entityRecord) else { return }
        await self.query.spawn(entity: entity, entityRecord: entityRecord)
    }
    
    public func despawn(entity: Entity) async {
        await self.query.despawn(entity: entity)
    }
    
    public func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) async {
        await self.query.applyCurrentState(entityRecord, forEntity: entity)
    }
    
    public static func getParameter(from worldStorage: WorldStorageRef) -> Filtered<Q, F>? {
        worldStorage.chunkStorage.chunk(ofType: Filtered<Q, F>.self)
    }
    
    public static func register(to worldStorage: WorldStorageRef) async {
        guard worldStorage.chunkStorage.chunk(ofType: Self.self) == nil else {
            return
        }
        
        await worldStorage.chunkStorage.addChunk(Filtered<Q, F>())
    }
    
    public func update(entity: Entity, _ execute: Q.Update) async {
        await self.query.update(entity, execute)
    }
    
}
