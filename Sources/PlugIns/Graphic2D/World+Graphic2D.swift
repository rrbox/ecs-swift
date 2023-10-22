//
//  World+Graphic2D.swift
//  
//
//  Created by rrbox on 2023/08/20.
//

import GameplayKit
import ECS

extension World {
    func setGraphic<Node: SKNode>(_ node: Node, forEntity entity: Entity) {
        node.userData = [:]
        node.userData!["ECS/Entity"] = entity
        let scene = self.worldBuffer.resourceBuffer.resource(ofType: SceneResource.self)?.resource.scene
        scene?.addChild(node)
        let entityRecord = self.entityRecord(forEntity: entity)!
        entityRecord.addComponent(GKSKNodeComponent(node: node))
        entityRecord.addComponent(GraphicDespawmDetector(nodeRef: node))
    }
    
    func removeGraphic(fromEntity entity: Entity) {
        let entityRecord = self.entityRecord(forEntity: entity)!
        entityRecord.removeComponent(ofType: GKSKNodeComponent.self)
        entityRecord.removeComponent(ofType: GraphicDespawmDetector.self)
    }
}

