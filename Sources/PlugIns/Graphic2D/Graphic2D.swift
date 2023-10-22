//
//  Graphic2D.swift
//  
//
//  Created by rrbox on 2023/08/18.
//

import GameplayKit
import ECS

public struct SceneResource: ResourceProtocol {
    public unowned let scene: SKScene
    public init(_ scene: SKScene) {
        self.scene = scene
    }
}

public struct Graphic<Node: SKNode>: Component {
    public unowned let nodeRef: Node
    init(node: Node) {
        self.nodeRef = node
    }
}

class GraphicDespawmDetector: GKComponent {
    unowned let nodeRef: SKNode
    init(nodeRef: SKNode) {
        self.nodeRef = nodeRef
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.nodeRef.removeFromParent()
    }
}

public extension SKNode {
    func ecsEntity() -> Entity {
        self.userData!["ECS/Entity"] as! Entity
    }
}
