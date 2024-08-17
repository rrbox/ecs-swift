//
//  KeyBoardPlugIn.swift
//  
//
//  Created by rrbox on 2023/08/05.
//

import ECS
import AppKit

public struct KeyDownEvent: EventProtocol {
    public let nsEvent: NSEvent
}

public struct KeyUpEvent: EventProtocol {
    public let nsEvent: NSEvent
}

public func keyBoardPlugIns(_ world: World) {
    world
        .addEventStreamer(eventType: KeyDownEvent.self)
        .addEventStreamer(eventType: KeyUpEvent.self)
}

public extension World {
    func keyDown(with event: NSEvent) {
        self.sendEvent(KeyDownEvent(nsEvent: event))
    }

    func keyUp(with event: NSEvent) {
        self.sendEvent(KeyUpEvent(nsEvent: event))
    }
}
