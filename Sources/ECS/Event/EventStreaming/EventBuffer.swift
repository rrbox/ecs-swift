//
//  EventBuffer.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

import Foundation

// world buffer にプロパティをつけておく
class EventBuffer {
    class EventWriterRegistry<T: EventProtocol>: BufferElement {
        let writer: EventWriter<T>
        init(writer: EventWriter<T>) {
            self.writer = writer
            super.init()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    let buffer: Buffer
    init(buffer: Buffer) {
        self.buffer = buffer
    }
    
    func setUpEventQueue() {
        self.buffer.addComponent(EventQueue())
    }
    
    func eventQueue() -> EventQueue? {
        self.buffer.component(ofType: EventQueue.self)
    }
    
    func eventWriter<T>(eventOfType type: T.Type) -> EventWriter<T>? {
        self.buffer.component(ofType: EventWriterRegistry<T>.self)?.writer
    }
    
    func registerEventWriter<T: EventProtocol>(eventType: T.Type) {
        let eventQueue = self.buffer.component(ofType: EventQueue.self)!
        self.buffer.addComponent(EventWriterRegistry<T>(writer: EventWriter<T>(eventQueue: eventQueue)))
    }
    
}

extension WorldBuffer {
    var eventBuffer: EventBuffer {
        EventBuffer(buffer: self)
    }
}

