//
//  EventStorage.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

import Foundation

enum EventStorage: WorldStorageType {}

protocol EventStorageElement: WorldStorageElement {}

extension AnyMap where Mode == EventStorage {
    mutating func push<T: EventStorageElement>(_ data: T) {
        self.body[ObjectIdentifier(T.self)] = Box(body: data)
    }

    mutating func pop<T: EventStorageElement>(_ type: T.Type) {
        self.body.removeValue(forKey: ObjectIdentifier(T.self))
    }

    func valueRef<T: EventStorageElement>(ofType type: T.Type) -> Box<T>? {
        guard let result = self.body[ObjectIdentifier(T.self)] else { return nil }
        return (result as! Box<T>)
    }
}

// world buffer にプロパティをつけておく

extension AnyMap<EventStorage> {
    mutating func registerEventQueues() {
        push(EventQueues())
    }

    mutating func registerEventStreamer<T: EventProtocol>(eventType: T.Type) {
        let queues = eventQueues()
        let queue = EventQueue<T>()
        queues?.body.append(queue)
        push(queue)
        push(EventWriter(queue: queue))
        push(EventReader(queue: queue))
    }

    func eventQueues() -> EventQueues? {
        valueRef(ofType: EventQueues.self)?.body
    }

    func eventWriter<T: EventProtocol>(typeOf type: T.Type) -> EventWriter<T>? {
        valueRef(ofType: EventWriter<T>.self)?.body
    }

    func eventQueue<T: EventProtocol>(typeOf type: T.Type) -> EventQueue<T>? {
        valueRef(ofType: EventQueue<T>.self)?.body
    }
}
