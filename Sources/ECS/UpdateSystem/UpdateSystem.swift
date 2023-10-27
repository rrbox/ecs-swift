//
//  UpdateSystem.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol UpdateSystemProtocol: SystemProtocol, UpdateExecute {
    
}

final public class UpdateSystem<Parameter: SystemParameter>: UpdateExecute, UpdateSystemProtocol {
    let execute: (Parameter) -> ()
    
    public init(_ execute: @escaping (Parameter) -> Void) {
        self.execute = execute
    }
    
    override func update(worldStorage: WorldStorageRef) {
        self.execute(Parameter.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addUpdateSystem<System: UpdateSystemProtocol>(_ system: System) -> World {
        self.worldStorage.systemStorage.addSystem(system, as: UpdateExecute.self)
        System.Parameter.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addUpdateSystem<Parameter: SystemParameter>(_ execute: @escaping (Parameter) -> ()) -> World {
        self.addUpdateSystem(UpdateSystem(execute))
    }
}
