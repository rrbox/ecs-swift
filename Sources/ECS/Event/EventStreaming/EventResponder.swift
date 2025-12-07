//
//  EventResponder.swift
//
//
//  Created by rrbox on 2023/11/11.
//

import Foundation

@available(*, deprecated)
final public class EventResponderBuilder {
    unowned let worldStorage: WorldStorageRef
    var systems: [EventSchedule: [SystemExecute]] = [:]

    init(worldStorage: WorldStorageRef) {
        self.worldStorage = worldStorage
    }
}

@available(*, deprecated)
final public class EventResponder<T>: EventStorageElement {
    var systems: [EventSchedule: [SystemExecute]] = [:]
}

public extension World {
    @available(*, deprecated)
    @discardableResult func buildEventResponder<T: EventProtocol>(_ eventType: T.Type, _ build: (EventResponderBuilder) -> ()) -> World {
        let builder = EventResponderBuilder(worldStorage: self.worldStorage)
        build(builder)

        self.worldStorage.eventStorage.eventResponder(eventOfType: T.self)!
            .systems
            .merge(builder.systems) { fromWorldStorage, new in
                fromWorldStorage + new
            }

        return self
    }

    @available(*, deprecated)
    private func buildCommandsEventResponder<T: CommandsEventProtocol>(_ eventType: T.Type, _ build: (EventResponderBuilder) -> ()) {
        let builder = EventResponderBuilder(worldStorage: self.worldStorage)
        build(builder)

        self.worldStorage.eventStorage.commandsEventResponder(eventOfType: T.self)!
            .systems
            .merge(builder.systems) { fromWorldStorage, new in
                fromWorldStorage + new
            }
    }

    @available(*, deprecated)
    @discardableResult func buildDidSpawnResponder(_ build: (EventResponderBuilder) -> ()) -> World {
        self.buildCommandsEventResponder(DidSpawnEvent.self, build)
        return self
    }

    @available(*, deprecated)
    @discardableResult func buildWillDespawnResponder(_ build: (EventResponderBuilder) -> ()) -> World {
        self.buildCommandsEventResponder(WillDespawnEvent.self, build)
        return self
    }
}
