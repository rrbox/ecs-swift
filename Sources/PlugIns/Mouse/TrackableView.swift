//
//  TrackableView.swift
//
//
//  Created by rrbox on 2023/10/09.
//

#if os(macOS)

import SpriteKit

class MouseTrackableView: SKView {
    var sceneTrackingArea: NSTrackingArea?

    func setTrackingArea() {
        let scene = self.scene!
        let trackingArea = NSTrackingArea(
            rect: frame,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways],
            owner: scene)
        self.addTrackingArea(trackingArea)
        self.sceneTrackingArea = trackingArea
    }

    override func updateTrackingAreas() {
        if let t = self.sceneTrackingArea {
            self.removeTrackingArea(t)
        }
        self.setTrackingArea()
    }
}

#endif
