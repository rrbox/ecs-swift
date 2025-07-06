//
//  CommandsEventWriter.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

final class CommandsEventWriter<T: CommandsEventProtocol>: SystemParameter, EventStorageElement {
    unowned let receiver: CommandsEventReceiver<T>

    init(receiver: CommandsEventReceiver<T>) {
        self.receiver = receiver
    }

    public func send(value: T) {
        receiver.eventBuffer.append(value)
    }

    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> CommandsEventWriter<T>? {
        worldStorage.eventStorage.commandsEventWriter(eventOfType: T.self)
    }
}
