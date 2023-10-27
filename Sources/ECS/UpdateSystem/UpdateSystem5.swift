//
//  UpdateSystem5.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol UpdateSystemProtocol5: SystemProtocol5, UpdateExecute {
    
}

final public class UpdateSystem5<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>: UpdateExecute, UpdateSystemProtocol5 {
    let execute: (P0, P1, P2, P3, P4) -> ()
    
    public init(_ execute: @escaping (P0, P1, P2, P3, P4) -> Void) {
        self.execute = execute
    }
    
    override func update(worldStorage: WorldStorageRef) {
        self.execute(P0.getParameter(from: worldStorage)!, P1.getParameter(from: worldStorage)!, P2.getParameter(from: worldStorage)!, P3.getParameter(from: worldStorage)!, P4.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addUpdateSystem<System: UpdateSystemProtocol5>(_ system: System) -> World {
        self.worldStorage.systemStorage.addSystem(system, as: UpdateExecute.self)
        System.P0.register(to: self.worldStorage)
        System.P1.register(to: self.worldStorage)
        System.P2.register(to: self.worldStorage)
        System.P3.register(to: self.worldStorage)
        System.P4.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addUpdateSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>(_ execute: @escaping (P0, P1, P2, P3, P4) -> ()) -> World {
        self.addUpdateSystem(UpdateSystem5(execute))
    }
}

