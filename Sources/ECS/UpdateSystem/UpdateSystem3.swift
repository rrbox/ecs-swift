//
//  UpdateSystem3.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol UpdateSystemProtocol3: SystemProtocol3, UpdateExecute {
    
}

final public class UpdateSystem3<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>: UpdateExecute, UpdateSystemProtocol3 {
    let execute: (P0, P1, P2) -> ()
    
    init(execute: @escaping (P0, P1, P2) -> Void) {
        self.execute = execute
    }
    
    override func update(worldBuffer: WorldBuffer) {
        self.execute(P0.getParameter(from: worldBuffer)!, P1.getParameter(from: worldBuffer)!, P2.getParameter(from: worldBuffer)!)
    }
}

public extension World {
    @discardableResult func addUpdateSystem<System: UpdateSystemProtocol3>(_ system: System) -> World {
        self.worldBuffer.systemBuffer.addSystem(system, as: UpdateExecute.self)
        System.P0.register(to: self.worldBuffer)
        System.P1.register(to: self.worldBuffer)
        System.P2.register(to: self.worldBuffer)
        return self
    }
    
    @discardableResult func addUpdateSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>(_ execute: @escaping (P0, P1, P2) -> ()) -> World {
        self.addUpdateSystem(UpdateSystem3(execute: execute))
    }
}
