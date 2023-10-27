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
        for system in worldStorage.systemStorage.systems(ofType: EventSystemExecute<T>.self) {
            system.receive(event: EventReader<T>(value: self.value), worldStorage: worldStorage)
        }
    }
}
