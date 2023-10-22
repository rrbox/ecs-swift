//
//  SetGraphic.swift
//  
//
//  Created by rrbox on 2023/08/20.
//

import SpriteKit
import ECS

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

