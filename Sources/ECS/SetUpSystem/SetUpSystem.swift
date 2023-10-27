//
//  SetUpSystem.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol SetUpSystemProtocol: SystemProtocol, SetUpExecute {
    
}

final public class SetUpSystem<Parameter: SetUpSystemParameter>: SetUpExecute, SetUpSystemProtocol {
    let execute: (Parameter) -> ()
    
    public init(_ execute: @escaping (Parameter) -> ()) {
        self.execute = execute
    }
    
    override func setUp(worldStorage: WorldStorageRef) {
        self.execute(Parameter.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addSetUpSystem<System: SetUpSystemProtocol>(_ system: System) -> World {
        self.addSystem(system, as: SetUpExecute.self)
        System.Parameter.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addSetUpSystem<Parameter: SetUpSystemParameter>(_ execute: @escaping (Parameter) -> ()) -> World {
        self.addSetUpSystem(SetUpSystem(execute))
    }
}
