//
//  EventWriter.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

// Commands と基本的な仕組みは同じ.
final public class EventWriter<T: EventProtocol>: SystemParameter, EventStorageElement {
    unowned let receiver: EventReceiver<T>

    init(receiver: EventReceiver<T>) {
        self.receiver = receiver
    }

    public func send(value: T) {
        receiver.eventBuffer.append(value)
    }

    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> EventWriter<T>? {
        worldStorage.eventStorage.eventWriter(eventOfType: T.self)
    }
}
