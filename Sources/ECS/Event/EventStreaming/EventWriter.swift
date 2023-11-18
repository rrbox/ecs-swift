//
//  EventWriter.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

// Commands と基本的な仕組みは同じ.
final public class EventWriter<T: EventProtocol>: SystemParameter, SetUpSystemParameter, BufferElement {
    unowned let eventQueue: EventQueue
    
    init(eventQueue: EventQueue) {
        self.eventQueue = eventQueue
    }
    
    public func send(value: T) {
        self.eventQueue.eventQueue.append(Event<T>(value: value))
    }
    
    public static func register(to worldBuffer: BufferRef) {
        
    }
    
    public static func getParameter(from worldBuffer: BufferRef) -> EventWriter<T>? {
        worldBuffer.eventBuffer.eventWriter(eventOfType: T.self)
    }
}
