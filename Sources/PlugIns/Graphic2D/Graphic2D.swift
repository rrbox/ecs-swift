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

class GraphicStrongRef: Component {
    let node: SKNode
    
    init(node: SKNode) {
        self.node = node
    }
    
    deinit {
        self.node.removeFromParent()
    }
}

public struct Graphic<Node: SKNode>: Component {
    public unowned let nodeRef: Node
    init(node: Node) {
        self.nodeRef = node
    }
}

public extension SKNode {
    func ecsEntity() -> Entity {
        self.userData!["ECS/Entity"] as! Entity
    }
}
