//
//  QueryProtocol.swift
//  
//
//  Created by rrbox on 2023/09/17.
//

public protocol QueryProtocol: Chunk {
    init()
    associatedtype Update
    func update(_ entity: Entity, _ execute: Update) async
}

extension Query: QueryProtocol {
    public typealias Update = (inout ComponentType) -> ()
}
extension Query2: QueryProtocol {
    public typealias Update = (inout C0, inout C1) -> ()
}
extension Query3: QueryProtocol {
    public typealias Update = (inout C0, inout C1, inout C2) -> ()
}
extension Query4: QueryProtocol {
    public typealias Update = (inout C0, inout C1, inout C2, inout C3) -> ()
}
extension Query5: QueryProtocol {
    public typealias Update = (inout C0, inout C1, inout C2, inout C3, inout C4) -> ()
}
