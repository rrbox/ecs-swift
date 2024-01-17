//
//  EventResponder.swift
//
//
//  Created by rrbox on 2023/11/11.
//

import Foundation

final public class EventResponderBuilder {
    unowned let worldStorage: WorldStorageRef
    var systems: [Schedule: [SystemExecute]] = [:]
    
    init(worldStorage: WorldStorageRef) {
        self.worldStorage = worldStorage
    }
}

final public class EventResponder<T>: WorldStorageElement {
    var systems: [Schedule: [SystemExecute]] = [:]
}

public extension World {
    @discardableResult func buildEventResponder<T: EventProtocol>(_ eventType: T.Type, _ build: (EventResponderBuilder) async -> ()) async -> World {
        let builder = EventResponderBuilder(worldStorage: self.worldStorage)
        await build(builder)
        
        self.worldStorage.eventStorage.eventResponder(eventOfType: T.self)!
            .systems
            .merge(builder.systems) { fromWorldStorage, new in
                fromWorldStorage + new
            }
        
        return self
    }
    
    private func buildCommandsEventResponder<T: CommandsEventProtocol>(_ eventType: T.Type, _ build: (EventResponderBuilder) -> ()) {
        let builder = EventResponderBuilder(worldStorage: self.worldStorage)
        build(builder)
        
        self.worldStorage.eventStorage.commandsEventResponder(eventOfType: T.self)!
            .systems
            .merge(builder.systems) { fromWorldStorage, new in
                fromWorldStorage + new
            }
    }
    
    @discardableResult func buildDidSpawnResponder(_ build: (EventResponderBuilder) -> ()) -> World {
        self.buildCommandsEventResponder(DidSpawnEvent.self, build)
        return self
    }
    
    @discardableResult func buildWillSpawnResponder(_ build: (EventResponderBuilder) -> ()) -> World {
        self.buildCommandsEventResponder(WillDespawnEvent.self, build)
        return self
    }
}
