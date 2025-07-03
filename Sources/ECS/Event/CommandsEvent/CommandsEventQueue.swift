//
//  CommandsEventQueue.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

final class CommandsEventQueue<T: CommandsEventProtocol>: EventStorageElement {
    var eventQueue = [T]()
    var sendingEvents = [T]()
}
