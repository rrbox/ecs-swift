//
//  EventSystem4.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final public class EventSystem4<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter>: EventSystemExecute<T> {
    let execute: (EventReader<T>, P0, P1, P2, P3) -> ()
    
    public init(execute: @escaping (EventReader<T>, P0, P1, P2, P3) -> ()) {
        self.execute = execute
    }
    
    override func receive(event: EventReader<T>, worldStorage: WorldStorageRef) {
        self.execute(event, P0.getParameter(from: worldStorage)!, P1.getParameter(from: worldStorage)!, P2.getParameter(from: worldStorage)!, P3.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter>(_ system: EventSystem4<T, P0, P1, P2, P3>) -> World {
        self.worldStorage.systemStorage.addSystem(system, as: EventSystemExecute<T>.self)
        P0.register(to: self.worldStorage)
        P1.register(to: self.worldStorage)
        P2.register(to: self.worldStorage)
        P3.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter>(_ execute: @escaping (EventReader<T>, P0, P1, P2, P3) -> ()) -> World {
        self.addEventSystem(EventSystem4<T, P0, P1, P2, P3>(execute: execute))
    }
}
