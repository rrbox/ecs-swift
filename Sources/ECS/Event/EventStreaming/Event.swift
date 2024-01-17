//
//  Event.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

public protocol EventProtocol {
    
}

class AnyEvent {
    func runEventReceiver(worldStorage: WorldStorageRef) async {
        
    }
}

final class Event<T: EventProtocol>: AnyEvent {
    let value: T
    init(value: T) {
        self.value = value
    }
    
    override func runEventReceiver(worldStorage: WorldStorageRef) async {
        worldStorage.map.push(EventReader(value: self.value))
        
        if let systems = worldStorage.eventStorage.eventResponder(eventOfType: T.self)!.systems[.update] {
            await withTaskGroup(of: Void.self) { group in
                for system in systems {
                    group.addTask {
                        await system.execute(worldStorage)
                    }
                }
            }
        }
        
        for schedule in worldStorage.stateStorage.currentSchedulesWhichAssociatedStates() {
            guard let systems = worldStorage.eventStorage.eventResponder(eventOfType: T.self)!.systems[schedule] else { continue }
            await withTaskGroup(of: Void.self) { group in
                for system in systems {
                    group.addTask {
                        await system.execute(worldStorage)
                    }
                }
            }
        }
        
        worldStorage.map.pop(EventReader<T>.self)
    }
}
