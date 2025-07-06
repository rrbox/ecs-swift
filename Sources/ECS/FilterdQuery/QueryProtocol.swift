//
//  QueryProtocol.swift
//  
//
//  Created by rrbox on 2023/09/17.
//

public protocol QueryProtocol: Chunk {
    associatedtype Update
    func insert(entityRecord: EntityRecordRef)
    func remove(entity: Entity)
    func allocate()
    func update( _ f: Update)
    func update(_ entity: Entity, _ f: Update)
    init()
}

extension Query: QueryProtocol {}
