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

struct OnEvent<T: EventProtocol>: Hashable {
    
}

public extension Schedule {
    static func onEvent<T: EventProtocol>(ofType: T.Type) -> Schedule {
        Schedule(id: OnEvent<T>())
    }
}

final class Event<T: EventProtocol>: AnyEvent {
    let value: T
    init(value: T) {
        self.value = value
    }
    
    override func runEventReceiver(worldStorage: WorldStorageRef) {
        worldStorage.map.push(EventReader(value: self.value))
        for system in worldStorage.systemStorage.systems(.onEvent(ofType: T.self)) {
            system.execute(worldStorage)
        }
        worldStorage.map.pop(EventReader<T>.self)
    }
}
