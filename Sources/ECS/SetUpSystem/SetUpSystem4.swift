//
//  SetUpSystem4.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol SetUpSystemProtocol4: SystemProtocol4, SetUpExecute {
    
}

final public class SetUpSystem4<P0: SetUpSystemParameter, P1: SetUpSystemParameter, P2: SetUpSystemParameter, P3: SetUpSystemParameter>: SetUpExecute, SetUpSystemProtocol4 {
    let execute: (P0, P1, P2, P3) -> ()
    
    public init(_ execute: @escaping (P0, P1, P2, P3) -> ()) {
        self.execute = execute
    }
    
    override func setUp(worldStorage: WorldStorageRef) {
        self.execute(
            P0.getParameter(from: worldStorage)!,
            P1.getParameter(from: worldStorage)!,
            P2.getParameter(from: worldStorage)!,
            P3.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addSetUpSystem<System: SetUpSystemProtocol4>(_ system: System) -> World {
        self.addSystem(system, as: SetUpExecute.self)
        System.P0.register(to: self.worldStorage)
        System.P1.register(to: self.worldStorage)
        System.P2.register(to: self.worldStorage)
        System.P3.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addSetUpSystem<P0: SetUpSystemParameter, P1: SetUpSystemParameter, P2: SetUpSystemParameter, P3: SetUpSystemParameter>(_ execute: @escaping (P0, P1, P2, P3) -> ()) -> World {
        self.addSetUpSystem(SetUpSystem4(execute))
    }
}
