//
//  CommandsEvent+WorldStorage.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

extension EventStorage {
    func setUpCommandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) {
        self.buffer.map.push(CommandsEventQueue<T>())
    }
    
    func commandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) -> CommandsEventQueue<T>? {
        self.buffer.map.valueRef(ofType: CommandsEventQueue<T>.self)?.body
    }
    
    func commandsEventWriter<T>(eventOfType type: T.Type) -> CommandsEventWriter<T>? {
        self.buffer.map.valueRef(ofType: CommandsEventWriter<T>.self)?.body
    }
    
    func registerCommandsEventWriter<T: CommandsEventProtocol>(eventType: T.Type) {
        let eventQueue = self.buffer.map.valueRef(ofType: CommandsEventQueue<T>.self)!.body
        self.buffer.map.push(CommandsEventWriter<T>(eventQueue: eventQueue))
    }
}
