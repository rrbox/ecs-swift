//
//  EventSystem2.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final public class EventSystem2<T, P0: SystemParameter, P1: SystemParameter>: EventSystemExecute<T> {
    let execute: (EventReader<T>, P0, P1) -> ()
    
    public init(execute: @escaping (EventReader<T>, P0, P1) -> ()) {
        self.execute = execute
    }
    
    override func receive(event: EventReader<T>, worldBuffer: WorldBuffer) {
        self.execute(event, P0.getParameter(from: worldBuffer)!, P1.getParameter(from: worldBuffer)!)
    }
}

public extension World {
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter>(_ system: EventSystem2<T, P0, P1>) -> World {
        self.worldBuffer.systemBuffer.addSystem(system, as: EventSystemExecute<T>.self)
        P0.register(to: self.worldBuffer)
        P1.register(to: self.worldBuffer)
        return self
    }
    
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter>(_ execute: @escaping (EventReader<T>, P0, P1) -> ()) -> World {
        self.addEventSystem(EventSystem2<T, P0, P1>(execute: execute))
    }
}

