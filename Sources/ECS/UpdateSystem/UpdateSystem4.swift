//
//  UpdateSystem4.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol UpdateSystemProtocol4: SystemProtocol4, UpdateExecute {
    
}

final public class UpdateSystem4<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter>: UpdateExecute, UpdateSystemProtocol4 {
    let execute: (P0, P1, P2, P3) -> ()
    
    public init(_ execute: @escaping (P0, P1, P2, P3) -> Void) {
        self.execute = execute
    }
    
    override func update(worldStorage: WorldStorageRef) {
        self.execute(P0.getParameter(from: worldStorage)!, P1.getParameter(from: worldStorage)!, P2.getParameter(from: worldStorage)!, P3.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addUpdateSystem<System: UpdateSystemProtocol4>(_ system: System) -> World {
        self.worldStorage.systemStorage.addSystem(system, as: UpdateExecute.self)
        System.P0.register(to: self.worldStorage)
        System.P1.register(to: self.worldStorage)
        System.P2.register(to: self.worldStorage)
        System.P3.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addUpdateSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter>(_ execute: @escaping (P0, P1, P2, P3) -> ()) -> World {
        self.addUpdateSystem(UpdateSystem4(execute))
    }
}
