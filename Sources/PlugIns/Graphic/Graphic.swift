//
//  Grahpic.swift
//  
//
//  Created by rrbox on 2023/08/18.
//

import GameplayKit
import ECS

public struct SceneResource: ResourceProtocol {
    public unowned let scene: SKNode
    public init(_ scene: SKNode) {
        self.scene = scene
    }
}

//class NodeBox: GKComponent {
//    let node: SKNode
//    init(node: SKNode) {
//        self.node = node
//        super.init()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

public class Graphic: Component {
    public unowned let nodeRef: SKNode
    init(node: SKNode) {
        self.nodeRef = node
    }
}

extension World {
    func setGraphic(_ node: SKNode, forEntity entity: Entity) {
        node.userData = [:]
        node.userData!["ECS/Entity"] = entity
        let scene = self.worldBuffer.resourceBuffer.resource(ofType: SceneResource.self)?.resource.scene
        scene?.addChild(node)
        let entityRecord = self.entityRecord(forEntity: entity)!
        entityRecord.addComponent(GKSKNodeComponent(node: node))
    }
    
    func removeGraphic(fromEntity entity: Entity) {
        let entityRecord = self.entityRecord(forEntity: entity)!
        let node = entityRecord.component(ofType: GKSKNodeComponent.self)!.node
        node.removeFromParent()
        entityRecord.removeComponent(ofType: GKSKNodeComponent.self)
    }
}

class SetGraphic: EntityCommand {
    let node: SKNode
    
    init(node: SKNode, entity: Entity) {
        self.node = node
        super.init(entity: entity)
    }
    
    override func runCommand(in world: World) {
        world.setGraphic(self.node, forEntity: self.entity)
    }
}

class RemoveGraphic: EntityCommand {
    override func runCommand(in world: World) {
        world.removeGraphic(fromEntity: self.entity)
    }
}

public extension EntityCommands {
    func setGraphic<Node: SKNode>(_ node: Node) -> EntityCommands {
        self.pushCommand(SetGraphic(node: node, entity: self.id()))
        return self.addComponent(Graphic(node: node))
    }
    
    func removeGraphic() -> EntityCommands {
        self.pushCommand(RemoveGraphic(entity: self.id()))
        return self.removeComponent(ofType: Graphic.self)
    }
}

public extension SKNode {
    func ecsEntity() -> Entity {
        self.userData!["ECS/Entity"] as! Entity
    }
}
