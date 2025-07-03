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
    mutating func setUpEventQueue() {
        push(EventQueue())
    }

    func eventQueue() -> EventQueue? {
        valueRef(ofType: EventQueue.self)?.body
    }

    func eventWriter<T>(eventOfType type: T.Type) -> EventWriter<T>? {
        valueRef(ofType: EventWriter<T>.self)?.body
    }

    mutating func registerEventWriter<T: EventProtocol>(eventType: T.Type) {
        let eventQueue = valueRef(ofType: EventQueue.self)!.body
        push(EventWriter<T>(eventQueue: eventQueue))
    }

    func eventResponder<T: EventProtocol>(eventOfType type: T.Type) -> EventResponder<T>? {
        valueRef(ofType: EventResponder<T>.self)?.body
    }

    mutating func registerEventResponder<T: EventProtocol>(eventType: T.Type) {
        push(EventResponder<T>())
    }
}
