//
//  SetUpSystem5.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol SetUpSystemProtocol5: SystemProtocol5, SetUpExecute {
    
}

final public class SetUpSystem5<P0: SetUpSystemParameter, P1: SetUpSystemParameter, P2: SetUpSystemParameter, P3: SetUpSystemParameter, P4: SetUpSystemParameter>: SetUpExecute, SetUpSystemProtocol5 {
    let execute: (P0, P1, P2, P3, P4) -> ()
    
    public init(_ execute: @escaping (P0, P1, P2, P3, P4) -> ()) {
        self.execute = execute
    }
    
    override func setUp(worldBuffer: BufferRef) {
        self.execute(
            P0.getParameter(from: worldBuffer)!,
            P1.getParameter(from: worldBuffer)!,
            P2.getParameter(from: worldBuffer)!,
            P3.getParameter(from: worldBuffer)!,
            P4.getParameter(from: worldBuffer)!)
    }
}

public extension World {
    @discardableResult func addSetUpSystem<System: SetUpSystemProtocol5>(_ system: System) -> World {
        self.addSystem(system, as: SetUpExecute.self)
        System.P0.register(to: self.worldBuffer)
        System.P1.register(to: self.worldBuffer)
        System.P2.register(to: self.worldBuffer)
        System.P3.register(to: self.worldBuffer)
        System.P4.register(to: self.worldBuffer)
        return self
    }
    
    @discardableResult func addSetUpSystem<P0: SetUpSystemParameter, P1: SetUpSystemParameter, P2: SetUpSystemParameter, P3: SetUpSystemParameter, P4: SetUpSystemParameter>(_ execute: @escaping (P0, P1, P2, P3, P4) -> ()) -> World {
        self.addSetUpSystem(SetUpSystem5(execute))
    }
}
