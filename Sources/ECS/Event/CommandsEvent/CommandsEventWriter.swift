//
//  CommandsEventWriter.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

final class CommandsEventWriter<T: CommandsEventProtocol>: SystemParameter, EventStorageElement {
    unowned let eventQueue: CommandsEventQueue<T>

    init(eventQueue: CommandsEventQueue<T>) {
        self.eventQueue = eventQueue
    }

    public func send(value: T) {
        self.eventQueue.eventQueue.append(value)
    }

    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> CommandsEventWriter<T>? {
        worldStorage.eventStorage.commandsEventWriter(eventOfType: T.self)
    }
}
