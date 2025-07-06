//
//  CommandsEvent+WorldStorage.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

extension AnyMap<EventStorage> {
    func commandsEventReceiver<T: CommandsEventProtocol>(eventOfType type: T.Type) -> CommandsEventReceiver<T>? {
        valueRef(ofType: CommandsEventReceiver<T>.self)?.body
    }

    mutating func registerCommandsEventReceiver<T: CommandsEventProtocol>(eventType: T.Type) {
        push(CommandsEventReceiver<T>())
    }

    func commandsEventWriter<T>(eventOfType type: T.Type) -> CommandsEventWriter<T>? {
        valueRef(ofType: CommandsEventWriter<T>.self)?.body
    }

    mutating func registerCommandsEventWriter<T: CommandsEventProtocol>(eventType: T.Type) {
        let receiver = valueRef(ofType: CommandsEventReceiver<T>.self)!.body
        push(CommandsEventWriter<T>(receiver: receiver))
    }

    func commandsEventResponder<T: CommandsEventProtocol>(eventOfType type: T.Type) -> EventResponder<T>? {
        valueRef(ofType: EventResponder<T>.self)?.body
    }

    mutating func resisterCommandsEventResponder<T: CommandsEventProtocol>(eventType: T.Type) {
        push(EventResponder<T>())
    }
}
