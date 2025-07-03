//
//  Event.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

public protocol EventProtocol {

}

class AnyEvent {
    func runEventReceiver(worldStorage: WorldStorageRef) {

    }
}

final class Event<T: EventProtocol>: AnyEvent {
    let value: T

    init(value: T) {
        self.value = value
    }

    override func runEventReceiver(worldStorage: WorldStorageRef) {
        worldStorage.eventStorage.push(EventReader(value: self.value))

        if let systems = worldStorage.eventStorage.eventResponder(eventOfType: T.self)!.systems[.update] {
            for system in systems {
                system.execute(worldStorage)
            }
        }

        for schedule in worldStorage.stateStorage.currentEventSchedulesWhichAssociatedStates() {
            guard let systems = worldStorage.eventStorage.eventResponder(eventOfType: T.self)!.systems[schedule] else { continue }
            for system in systems {
                system.execute(worldStorage)
            }
        }

        worldStorage.eventStorage.pop(EventReader<T>.self)
    }
}
