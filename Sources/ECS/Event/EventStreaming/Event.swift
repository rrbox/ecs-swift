//
//  Event.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

public protocol EventProtocol {
    
}

class AnyEvent {
    func runEventReceiver(worldBuffer: BufferRef) {
        
    }
}

final class Event<T: EventProtocol>: AnyEvent {
    let value: T
    init(value: T) {
        self.value = value
    }
    
    override func runEventReceiver(worldBuffer: BufferRef) {
        for system in worldBuffer.systemStorage.systems(ofType: EventSystemExecute<T>.self) {
            system.receive(event: EventReader<T>(value: self.value), worldBuffer: worldBuffer)
        }
    }
}
