//
//  CommandsEvent+WorldStorage.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

extension AnyMap<EventStorage> {
    @available(*, deprecated)
    func commandsEventReceiver<T: CommandsEventProtocol>(eventOfType type: T.Type) -> CommandsEventReceiver<T>? {
        valueRef(ofType: CommandsEventReceiver<T>.self)?.body
    }

    @available(*, deprecated)
    mutating func registerCommandsEventReceiver<T: CommandsEventProtocol>(eventType: T.Type) {
        push(CommandsEventReceiver<T>())
    }

    @available(*, deprecated)
    func commandsEventWriter<T>(eventOfType type: T.Type) -> CommandsEventWriter<T>? {
        valueRef(ofType: CommandsEventWriter<T>.self)?.body
    }

    @available(*, deprecated)
    mutating func registerCommandsEventWriter<T: CommandsEventProtocol>(eventType: T.Type) {
        let receiver = valueRef(ofType: CommandsEventReceiver<T>.self)!.body
        push(CommandsEventWriter<T>(receiver: receiver))
    }

    @available(*, deprecated)
    func commandsEventResponder<T: CommandsEventProtocol>(eventOfType type: T.Type) -> EventResponder<T>? {
        valueRef(ofType: EventResponder<T>.self)?.body
    }

    @available(*, deprecated)
    mutating func resisterCommandsEventResponder<T: CommandsEventProtocol>(eventType: T.Type) {
        push(EventResponder<T>())
    }
}
