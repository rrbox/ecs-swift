//
//  UpdateSystem2.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol UpdateSystemProtocol2: SystemProtocol2, UpdateExecute {
    
}

final public class UpdateSystem2<P0: SystemParameter, P1: SystemParameter>: UpdateExecute, UpdateSystemProtocol2 {
    let execute: (P0, P1) -> ()
    
    public init(_ execute: @escaping (P0, P1) -> Void) {
        self.execute = execute
    }
    
    override func update(worldBuffer: BufferRef) {
        self.execute(P0.getParameter(from: worldBuffer)!, P1.getParameter(from: worldBuffer)!)
    }
}

public extension World {
    @discardableResult func addUpdateSystem<System: UpdateSystemProtocol2>(_ system: System) -> World {
        self.worldBuffer.systemStorage.addSystem(system, as: UpdateExecute.self)
        System.P0.register(to: self.worldBuffer)
        System.P1.register(to: self.worldBuffer)
        return self
    }
    
    @discardableResult func addUpdateSystem<P0: SystemParameter, P1: SystemParameter>(_ execute: @escaping (P0, P1) -> ()) -> World {
        self.addUpdateSystem(UpdateSystem2(execute))
    }
}
