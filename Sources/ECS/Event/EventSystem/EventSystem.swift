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
    
    override func receive(event: EventReader<T>, worldBuffer: BufferRef) {
        self.execute(event, Parameter.getParameter(from: worldBuffer)!)
    }
}

public extension World {
    @discardableResult func addEventSystem<T, Parameter: SystemParameter>(_ system: EventSystem<T, Parameter>) -> World {
        self.worldBuffer.systemBuffer.addSystem(system, as: EventSystemExecute<T>.self)
        Parameter.register(to: self.worldBuffer)
        return self
    }
    
    @discardableResult func addEventSystem<T, Parameter: SystemParameter>(_ execute: @escaping (EventReader<T>, Parameter) -> ()) -> World {
        self.addEventSystem(EventSystem<T, Parameter>(execute: execute))
    }
}
