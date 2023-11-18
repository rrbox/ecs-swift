//
//  SetUpSystem2.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol SetUpSystemProtocol2: SystemProtocol2, SetUpExecute {
    
}

final public class SetUpSystem2<P0: SetUpSystemParameter, P1: SetUpSystemParameter>: SetUpExecute, SetUpSystemProtocol2 {
    let execute: (P0, P1) -> ()
    
    public init(_ execute: @escaping (P0, P1) -> ()) {
        self.execute = execute
    }
    
    override func setUp(worldBuffer: BufferRef) {
        self.execute(
            P0.getParameter(from: worldBuffer)!,
            P1.getParameter(from: worldBuffer)!)
    }
}

public extension World {
    @discardableResult func addSetUpSystem<System: SetUpSystemProtocol2>(_ system: System) -> World {
        self.addSystem(system, as: SetUpExecute.self)
        System.P0.register(to: self.worldBuffer)
        System.P1.register(to: self.worldBuffer)
        return self
    }
    
    @discardableResult func addSetUpSystem<P0: SetUpSystemParameter, P1: SetUpSystemParameter>(_ execute: @escaping (P0, P1) -> ()) -> World {
        self.addSetUpSystem(SetUpSystem2(execute))
    }
}
