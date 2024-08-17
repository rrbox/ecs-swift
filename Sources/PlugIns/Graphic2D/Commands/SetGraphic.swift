//
//  SetGraphic.swift
//  
//
//  Created by rrbox on 2023/08/20.
//

import SpriteKit
import ECS

struct _AddChildNodeTransaction: Component {
    var parentEntity: Entity?
}

class SetGraphic: EntityCommand {
    let node: SKNode

    init(node: SKNode, entity: Entity) {
        self.node = node
        super.init(entity: entity)
    }

    func setEntityInfoForNode(_ entity: Entity) {
        self.node.userData = [:]
        self.node.userData!["ECS/Entity"] = entity
    }

    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        self.setEntityInfoForNode(entity)
        
        record.addComponent(GraphicStrongRef(node: self.node))
        record.addComponent(Parent(_children: []))
        record.addComponent(_AddChildNodeTransaction(parentEntity: nil))
    }
     
}
