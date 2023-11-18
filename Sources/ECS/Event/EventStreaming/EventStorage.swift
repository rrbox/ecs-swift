//
//  EventStorage.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

import Foundation

// world buffer にプロパティをつけておく
class EventStorage {
    let buffer: WorldStorageRef
    init(buffer: WorldStorageRef) {
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

extension WorldStorageRef {
    var eventStorage: EventStorage {
        EventStorage(buffer: self)
    }
}

