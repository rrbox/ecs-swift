//
//  MousePlugIn.swift
//  
//
//  Created by rrbox on 2023/08/05.
//

import ECS
import AppKit

public struct MouseEnteredEvent: EventProtocol {
    public let nsEvent: NSEvent
}

public struct MouseExitedEvent: EventProtocol {
    public let nsEvent: NSEvent
}

public struct MouseMovedEvent: EventProtocol {
    public let nsEvent: NSEvent
}

public struct MouseDownEvent: EventProtocol {
    public let nsEvent: NSEvent
}

public struct MouseDraggedEvent: EventProtocol {
    public let nsEvent: NSEvent
}

public struct MouseUpEvent: EventProtocol {
    public let nsEvent: NSEvent
}

public func mousePlugIns(_ world: World) {
    world
        .addEventStreamer(eventType: MouseEnteredEvent.self)
        .addEventStreamer(eventType: MouseExitedEvent.self)
        .addEventStreamer(eventType: MouseMovedEvent.self)
        .addEventStreamer(eventType: MouseDownEvent.self)
        .addEventStreamer(eventType: MouseDraggedEvent.self)
        .addEventStreamer(eventType: MouseUpEvent.self)
}

public extension World {
    func mouseEntered(with event: NSEvent) {
        self.sendEvent(MouseEnteredEvent(nsEvent: event))
    }
    
    func mouseExited(with event: NSEvent) {
        self.sendEvent(MouseExitedEvent(nsEvent: event))
    }
    
    func mouseMoved(with event: NSEvent) {
        self.sendEvent(MouseMovedEvent(nsEvent: event))
    }
    
    func mouseDown(with event: NSEvent) {
        self.sendEvent(MouseDownEvent(nsEvent: event))
    }
    
    func mouseDragged(with event: NSEvent) {
        self.sendEvent(MouseDraggedEvent(nsEvent: event))
    }
    
    func mouseUp(with event: NSEvent) {
        self.sendEvent(MouseUpEvent(nsEvent: event))
    }
}
