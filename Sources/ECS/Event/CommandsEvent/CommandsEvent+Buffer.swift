//
//  CommandsEvent+WorldStorage.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

extension AnyMap<EventStorage> {
    mutating func setUpCommandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) {
        push(CommandsEventQueue<T>())
    }

    func commandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) -> CommandsEventQueue<T>? {
        valueRef(ofType: CommandsEventQueue<T>.self)?.body
    }

    func commandsEventWriter<T>(eventOfType type: T.Type) -> CommandsEventWriter<T>? {
        valueRef(ofType: CommandsEventWriter<T>.self)?.body
    }

    mutating func registerCommandsEventWriter<T: CommandsEventProtocol>(eventType: T.Type) {
        let eventQueue = valueRef(ofType: CommandsEventQueue<T>.self)!.body
        push(CommandsEventWriter<T>(eventQueue: eventQueue))
    }

    func commandsEventResponder<T: CommandsEventProtocol>(eventOfType type: T.Type) -> EventResponder<T>? {
        valueRef(ofType: EventResponder<T>.self)?.body
    }

    mutating func resisterCommandsEventResponder<T: CommandsEventProtocol>(eventType: T.Type) {
        push(EventResponder<T>())
    }
}
