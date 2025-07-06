//
//  CommandsEventReceiver.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/07/06.
//

final class CommandsEventReceiver<T: CommandsEventProtocol>: AnyEventReceiver, EventStorageElement {
    var eventBuffer = [T]()

    override func receive(worldStorage: WorldStorageRef) {
        let events = eventBuffer
        eventBuffer = []
        guard !events.isEmpty else { return }
        worldStorage.eventStorage.push(EventReader(events: events))
        if let systems = worldStorage.eventStorage.commandsEventResponder(eventOfType: T.self)!.systems[.update] {
            for system in systems {
                system.execute(worldStorage)
            }
        }
        for schedule in worldStorage.stateStorage.currentEventSchedulesWhichAssociatedStates() {
            guard let systems = worldStorage.eventStorage.commandsEventResponder(eventOfType: T.self)!.systems[schedule] else { continue }
            for system in systems {
                system.execute(worldStorage)
            }
        }
        worldStorage.eventStorage.pop(EventReader<T>.self)
    }
}
