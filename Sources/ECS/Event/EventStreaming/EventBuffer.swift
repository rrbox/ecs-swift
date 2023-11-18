//
//  EventBuffer.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

import Foundation

// world buffer にプロパティをつけておく
class EventBuffer {
    let buffer: BufferRef
    init(buffer: BufferRef) {
        self.buffer = buffer
    }
    
    func setUpEventQueue() {
        self.buffer.map.push(EventQueue())
    }
    
    func eventQueue() -> EventQueue? {
        self.buffer.map.valueRef(ofType: EventQueue.self)?.body
    }
    
    func eventWriter<T>(eventOfType type: T.Type) -> EventWriter<T>? {
        self.buffer.map.valueRef(ofType: EventWriter<T>.self)?.body
    }
    
    func registerEventWriter<T: EventProtocol>(eventType: T.Type) {
        let eventQueue = self.buffer.map.valueRef(ofType: EventQueue.self)!.body
        self.buffer.map.push(EventWriter<T>(eventQueue: eventQueue))
    }
    
}

extension BufferRef {
    var eventBuffer: EventBuffer {
        EventBuffer(buffer: self)
    }
}

