//
//  EventSystem3.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final public class EventSystem3<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>: EventSystemExecute<T> {
    let execute: (EventReader<T>, P0, P1, P2) -> ()
    
    public init(execute: @escaping (EventReader<T>, P0, P1, P2) -> ()) {
        self.execute = execute
    }
    
    override func receive(event: EventReader<T>, worldBuffer: BufferRef) {
        self.execute(event, P0.getParameter(from: worldBuffer)!, P1.getParameter(from: worldBuffer)!, P2.getParameter(from: worldBuffer)!)
    }
}

public extension World {
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>(_ system: EventSystem3<T, P0, P1, P2>) -> World {
        self.worldBuffer.systemStorage.addSystem(system, as: EventSystemExecute<T>.self)
        P0.register(to: self.worldBuffer)
        P1.register(to: self.worldBuffer)
        P2.register(to: self.worldBuffer)
        return self
    }
    
    @discardableResult func addEventSystem<T, P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>(_ execute: @escaping (EventReader<T>, P0, P1, P2) -> ()) -> World {
        self.addEventSystem(EventSystem3<T, P0, P1, P2>(execute: execute))
    }
}
