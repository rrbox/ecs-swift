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
    
    public init(_ execute: @escaping (P0, P1, P2) -> Void) {
        self.execute = execute
    }
    
    override func update(worldStorage: WorldStorageRef) {
        self.execute(P0.getParameter(from: worldStorage)!, P1.getParameter(from: worldStorage)!, P2.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addUpdateSystem<System: UpdateSystemProtocol3>(_ system: System) -> World {
        self.worldStorage.systemStorage.addSystem(system, as: UpdateExecute.self)
        System.P0.register(to: self.worldStorage)
        System.P1.register(to: self.worldStorage)
        System.P2.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addUpdateSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>(_ execute: @escaping (P0, P1, P2) -> ()) -> World {
        self.addUpdateSystem(UpdateSystem3(execute))
    }
}
