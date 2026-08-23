//
//  EventWriter.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final public class EventWriter<T: EventProtocol>: SystemParameter, EventStorageElement {
    unowned let queue: EventQueue<T>

    init(queue: EventQueue<T>) {
        self.queue = queue
    }

    public func send(_ value: T) {
        queue.write(event: value)
    }

    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> EventWriter<T>? {
        worldStorage
            .eventStorage
            .valueRef(ofType: EventWriter<T>.self)?
            .body
    }
}
