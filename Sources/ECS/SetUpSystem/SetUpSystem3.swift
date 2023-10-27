//
//  SetUpSystem3.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol SetUpSystemProtocol3: SystemProtocol3, SetUpExecute {
    
}

final public class SetUpSystem3<P0: SetUpSystemParameter, P1: SetUpSystemParameter, P2: SetUpSystemParameter>: SetUpExecute, SetUpSystemProtocol3 {
    let execute: (P0, P1, P2) -> ()
    
    public init(_ execute: @escaping (P0, P1, P2) -> ()) {
        self.execute = execute
    }
    
    override func setUp(worldStorage: WorldStorageRef) {
        self.execute(
            P0.getParameter(from: worldStorage)!,
            P1.getParameter(from: worldStorage)!,
            P2.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addSetUpSystem<System: SetUpSystemProtocol3>(_ system: System) -> World {
        self.addSystem(system, as: SetUpExecute.self)
        System.P0.register(to: self.worldStorage)
        System.P1.register(to: self.worldStorage)
        System.P2.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addSetUpSystem<P0: SetUpSystemParameter, P1: SetUpSystemParameter, P2: SetUpSystemParameter>(_ execute: @escaping (P0, P1, P2) -> ()) -> World {
        self.addSetUpSystem(SetUpSystem3(execute))
    }
}
