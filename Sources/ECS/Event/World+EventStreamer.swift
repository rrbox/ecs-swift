//
//  World+EventStreamer.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

public extension World {
    /// `T` 型の値をイベントとして送受信するためのセットアップです.
    ///
    /// `Event<T>` をイベントシステムで扱う前に, World に EventStreamer を追加する必要があります.
    @discardableResult func addEventStreamer<T: EventProtocol>(eventType: T.Type) -> World {
        self.worldBuffer.systemBuffer.registerSystemRegistry(ofType: EventSystemExecute<T>.self)
        self.worldBuffer.eventStorage.registerEventWriter(eventType: T.self)
        return self
    }
}

extension World {
    func addCommandsEventStreamer<T: CommandsEventProtocol>(eventType: T.Type) {
        self.worldBuffer.systemBuffer.registerSystemRegistry(ofType: EventSystemExecute<T>.self)
        self.worldBuffer.eventStorage.registerCommandsEventWriter(eventType: T.self)
    }
}

extension World {
    func applyEventQueue() {
        let eventQueue = self.worldBuffer.eventStorage.eventQueue()!
        eventQueue.sendingEvents = eventQueue.eventQueue
        eventQueue.eventQueue = []
        for event in eventQueue.sendingEvents {
            event.runEventReceiver(worldBuffer: self.worldBuffer)
        }
        eventQueue.sendingEvents = []
    }
    
    func applyCommandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) {
        let eventQueue = self.worldBuffer.eventStorage.commandsEventQueue(eventOfType: T.self)!
        eventQueue.sendingEvents = eventQueue.eventQueue
        eventQueue.eventQueue = []
        for event in eventQueue.sendingEvents {
            for system in self.worldBuffer.systemBuffer.systems(ofType: EventSystemExecute<T>.self) {
                system.receive(event: EventReader(value: event), worldBuffer: self.worldBuffer)
            }
        }
        eventQueue.sendingEvents = []
    }
}

public extension World {
    func sendEvent<T: EventProtocol>(_ value: T) {
        self.worldBuffer.eventStorage.eventWriter(eventOfType: T.self)?.send(value: value)
    }
}
