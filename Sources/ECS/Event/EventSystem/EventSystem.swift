//
//  EventSystem.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final public class EventSystem<T, Parameter: SystemParameter>: EventSystemExecute<T> {
    let execute: (EventReader<T>, Parameter) -> ()
    
    public init(execute: @escaping (EventReader<T>, Parameter) -> ()) {
        self.execute = execute
    }
    
    override func receive(event: EventReader<T>, worldStorage: WorldStorageRef) {
        self.execute(event, Parameter.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addEventSystem<T, Parameter: SystemParameter>(_ system: EventSystem<T, Parameter>) -> World {
        self.worldStorage.systemStorage.addSystem(system, as: EventSystemExecute<T>.self)
        Parameter.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addEventSystem<T, Parameter: SystemParameter>(_ execute: @escaping (EventReader<T>, Parameter) -> ()) -> World {
        self.addEventSystem(EventSystem<T, Parameter>(execute: execute))
    }
}
