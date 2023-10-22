//
//  Camera.swift
//
//
//  Created by rrbox on 2023/10/09.
//

import SpriteKit
import ECS

public struct Camera: ResourceProtocol {
    public let camera: SKCameraNode
    
    public static func setDefaultCamera(scene: SKScene) -> Camera {
        let cameraNode = SKCameraNode()
        scene.camera = cameraNode
        return Camera(camera: cameraNode)
    }
    
    public static func createFrom(cameraNamed name: String, inScene scene: SKScene) -> Camera {
        let cameraNode = scene.childNode(withName: name) as! SKCameraNode
        return Camera(camera: cameraNode)
    }
}

