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
        self.worldStorage.systemStorage.registerSystemRegistry(ofType: EventSystemExecute<T>.self)
        self.worldStorage.eventStorage.registerEventWriter(eventType: T.self)
        return self
    }
}

extension World {
    func addCommandsEventStreamer<T: CommandsEventProtocol>(eventType: T.Type) {
        self.worldStorage.systemStorage.registerSystemRegistry(ofType: EventSystemExecute<T>.self)
        self.worldStorage.eventStorage.registerCommandsEventWriter(eventType: T.self)
    }
}

extension World {
    func applyEventQueue() {
        let eventQueue = self.worldStorage.eventStorage.eventQueue()!
        eventQueue.sendingEvents = eventQueue.eventQueue
        eventQueue.eventQueue = []
        for event in eventQueue.sendingEvents {
            event.runEventReceiver(worldStorage: self.worldStorage)
        }
        eventQueue.sendingEvents = []
    }
    
    func applyCommandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) {
        let eventQueue = self.worldStorage.eventStorage.commandsEventQueue(eventOfType: T.self)!
        eventQueue.sendingEvents = eventQueue.eventQueue
        eventQueue.eventQueue = []
        for event in eventQueue.sendingEvents {
            for system in self.worldStorage.systemStorage.systems(ofType: EventSystemExecute<T>.self) {
                system.receive(event: EventReader(value: event), worldStorage: self.worldStorage)
            }
        }
        eventQueue.sendingEvents = []
    }
}

public extension World {
    func sendEvent<T: EventProtocol>(_ value: T) {
        self.worldStorage.eventStorage.eventWriter(eventOfType: T.self)?.send(value: value)
    }
}
