//
//  QueryProtocol.swift
//  
//
//  Created by rrbox on 2023/09/17.
//

public protocol QueryProtocol {
    func spawn(entity: Entity, entityRecord: EntityRecord)
    func despawn(entity: Entity)
    init()
}

extension Query: QueryProtocol {}
extension Query2: QueryProtocol {}
extension Query3: QueryProtocol {}
extension Query4: QueryProtocol {}
extension Query5: QueryProtocol {}
