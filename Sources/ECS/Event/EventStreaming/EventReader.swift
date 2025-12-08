//
//  EventReader.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final public class Removed: SystemParameter, EventStorageElement {
    public let entities: [Entity]

    init(entities: [Entity]) {
        self.entities = entities
    }

    public func forEach(_ body: (Entity) -> ()) {
        entities.forEach(body)
    }

    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> Removed? {
        worldStorage.eventStorage.valueRef(ofType: Removed.self)?.body
    }
}

final public class EventReader<T: EventProtocol>: SystemParameter, EventStorageElement {
    unowned let queue: EventQueue<T>

    init(queue: EventQueue<T>) {
        self.queue = queue
    }

    public var count: Int {
        queue.countOfEvents
    }

    public var isEmpty: Bool {
        count == 0
    }

    public func forEach(_ body: (T) -> ()) {
        queue.forEach(body)
    }

    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> EventReader<T>? {
        worldStorage
            .eventStorage
            .valueRef(ofType: EventReader<T>.self)?
            .body
    }
}
