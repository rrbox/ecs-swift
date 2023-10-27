//
//  EventSystem5.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final public class EventSystem5<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>: EventSystemExecute<T> {
    let execute: (EventReader<T>, P0, P1, P2, P3, P4) -> ()
    
    public init(execute: @escaping (EventReader<T>, P0, P1, P2, P3, P4) -> ()) {
        self.execute = execute
    }
    
    override func receive(event: EventReader<T>, worldStorage: WorldStorageRef) {
        self.execute(event, P0.getParameter(from: worldStorage)!, P1.getParameter(from: worldStorage)!, P2.getParameter(from: worldStorage)!, P3.getParameter(from: worldStorage)!, P4.getParameter(from: worldStorage)!)
    }
}

public extension World {
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>(_ system: EventSystem5<T, P0, P1, P2, P3, P4>) -> World {
        self.worldStorage.systemStorage.addSystem(system, as: EventSystemExecute<T>.self)
        P0.register(to: self.worldStorage)
        P1.register(to: self.worldStorage)
        P2.register(to: self.worldStorage)
        P3.register(to: self.worldStorage)
        P4.register(to: self.worldStorage)
        return self
    }
    
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>(_ execute: @escaping (EventReader<T>, P0, P1, P2, P3, P4) -> ()) -> World {
        self.addEventSystem(EventSystem5<T, P0, P1, P2, P3, P4>(execute: execute))
    }
}
