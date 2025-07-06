//
//  EventReader.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final public class EventReader<T>: SystemParameter, EventStorageElement {
    public let events: [T]

    init(events: [T]) {
        self.events = events
    }

    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> EventReader<T>? {
        return worldStorage.eventStorage.valueRef(ofType: EventReader<T>.self)?.body
    }
}
