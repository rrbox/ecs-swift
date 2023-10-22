//
//  CommandsEventWriter.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

final class CommandsEventWriter<T: CommandsEventProtocol>: SystemParameter, SetUpSystemParameter {
    unowned let eventQueue: CommandsEventQueue<T>
    
    init(eventQueue: CommandsEventQueue<T>) {
        self.eventQueue = eventQueue
    }
    
    public func send(value: T) {
        self.eventQueue.eventQueue.append(value)
    }
    
    public static func register(to worldBuffer: WorldBuffer) {
        
    }
    
    public static func getParameter(from worldBuffer: WorldBuffer) -> CommandsEventWriter<T>? {
        worldBuffer.eventBuffer.commandsEventWriter(eventOfType: T.self)
    }
}

