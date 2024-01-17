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
        let eventStorage = self.worldStorage.eventStorage
        eventStorage.registerEventWriter(eventType: T.self)
        eventStorage.registerEventResponder(eventType: T.self)
        
        return self
    }
}

extension World {
    func addCommandsEventStreamer<T: CommandsEventProtocol>(eventType: T.Type) {
        self.worldStorage.systemStorage.insertSchedule(.onCommandsEvent(ofType: T.self))
        
        let eventStorage = self.worldStorage.eventStorage
        eventStorage.registerCommandsEventWriter(eventType: T.self)
        eventStorage.resisterCommandsEventResponder(eventType: T.self)
    }
}

extension World {
    func applyEventQueue() async {
        let eventQueue = self.worldStorage.eventStorage.eventQueue()!
        eventQueue.sendingEvents = eventQueue.eventQueue
        eventQueue.eventQueue = []
        await withTaskGroup(of: Void.self) { group in
            for event in eventQueue.sendingEvents {
                group.addTask {
                    await event.runEventReceiver(worldStorage: self.worldStorage)
                }
            }
        }
        
        eventQueue.sendingEvents = []
    }
    
    func applyCommandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) async {
        let eventStorage = self.worldStorage.eventStorage
        let eventQueue = eventStorage.commandsEventQueue(eventOfType: T.self)!
        eventQueue.sendingEvents = eventQueue.eventQueue
        eventQueue.eventQueue = []
        for event in eventQueue.sendingEvents {
            self.worldStorage.map.push(EventReader(value: event))
            
            if let systems = eventStorage.commandsEventResponder(eventOfType: T.self)!.systems[.update] {
                await withTaskGroup(of: Void.self) { group in
                    for system in systems {
                        group.addTask {
                            await system.execute(self.worldStorage)
                        }
                    }
                }
            }
            
            for schedule in self.worldStorage.stateStorage.currentSchedulesWhichAssociatedStates() {
                guard let systems = eventStorage.commandsEventResponder(eventOfType: T.self)!.systems[schedule] else { continue }
                await withTaskGroup(of: Void.self) { group in
                    for system in systems {
                        group.addTask {
                            await system.execute(self.worldStorage)
                        }
                    }
                }
            }
            
            self.worldStorage.map.pop(EventReader<T>.self)
        }
        eventQueue.sendingEvents = []
    }
}

public extension World {
    /**
     ``World`` インスタンスを介して Event を配信します.
     
     System 内で Event を発信する場合は ``EventWriter`` を参照してください.
     */
    func sendEvent<T: EventProtocol>(_ value: T) {
        self.worldStorage.eventStorage.eventWriter(eventOfType: T.self)?.send(value: value)
    }
}
