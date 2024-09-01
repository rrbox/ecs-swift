//
//  Touch.swift
//
//
//  Created by rrbox on 2024/09/01.
//

#if os(iOS)

import ECS
import UIKit

public struct TouchesBeganEvent: EventProtocol {
    public let touches: Set<UITouch>
    public let withEvent: UIEvent?
}

public struct TouchesMovedEvent: EventProtocol {
    public let touches: Set<UITouch>
    public let withEvent: UIEvent?
}

public struct TouchesEndedEvent: EventProtocol {
    public let touches: Set<UITouch>
    public let withEvent: UIEvent?
}

public struct TouchesCancelled: EventProtocol {
    public let touches: Set<UITouch>
    public let withEvent: UIEvent?
}

public func touchPlugIns(_ world: World) {
    world
        .addEventStreamer(eventType: TouchesBeganEvent.self)
        .addEventStreamer(eventType: TouchesMovedEvent.self)
        .addEventStreamer(eventType: TouchesEndedEvent.self)
        .addEventStreamer(eventType: TouchesCancelled.self)
}

public extension World {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.sendEvent(TouchesBeganEvent(touches: touches, withEvent: event))
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.sendEvent(TouchesMovedEvent(touches: touches, withEvent: event))
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.sendEvent(TouchesEndedEvent(touches: touches, withEvent: event))
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.sendEvent(TouchesCancelled(touches: touches, withEvent: event))
    }
}

#endif

