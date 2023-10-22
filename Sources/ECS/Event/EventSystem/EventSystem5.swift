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
    
    override func receive(event: EventReader<T>, worldBuffer: WorldBuffer) {
        self.execute(event, P0.getParameter(from: worldBuffer)!, P1.getParameter(from: worldBuffer)!, P2.getParameter(from: worldBuffer)!, P3.getParameter(from: worldBuffer)!, P4.getParameter(from: worldBuffer)!)
    }
}

public extension World {
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>(_ system: EventSystem5<T, P0, P1, P2, P3, P4>) -> World {
        self.worldBuffer.systemBuffer.addSystem(system, as: EventSystemExecute<T>.self)
        P0.register(to: self.worldBuffer)
        P1.register(to: self.worldBuffer)
        P2.register(to: self.worldBuffer)
        P3.register(to: self.worldBuffer)
        P4.register(to: self.worldBuffer)
        return self
    }
    
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>(_ execute: @escaping (EventReader<T>, P0, P1, P2, P3, P4) -> ()) -> World {
        self.addEventSystem(EventSystem5<T, P0, P1, P2, P3, P4>(execute: execute))
    }
}
