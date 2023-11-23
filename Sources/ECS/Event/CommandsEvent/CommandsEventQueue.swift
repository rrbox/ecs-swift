//
//  CommandsEventQueue.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

class CommandsEventQueue<T: CommandsEventProtocol>: WorldStorageElement {
    var eventQueue = [T]()
    var sendingEvents = [T]()
}
