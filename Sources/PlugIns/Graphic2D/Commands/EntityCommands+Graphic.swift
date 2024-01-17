//
//  EntityCommands+Graphic.swift
//  
//
//  Created by rrbox on 2023/08/20.
//

import SpriteKit
import ECS

public extension EntityCommands {
    @discardableResult func setGraphic<Node: SKNode>(_ node: Node) async -> EntityCommands {
        await self.pushCommand(SetGraphic(node: node, entity: self.id()))
        return await self.addComponent(Graphic(node: node)).addComponent(Graphic<SKNode>(node: node))
    }
    
    @discardableResult func removeGraphic() async -> EntityCommands {
        await self.pushCommand(RemoveGraphic(entity: self.id()))
        return await self.removeComponent(ofType: Graphic.self).removeComponent(ofType: Graphic<SKNode>.self)
    }
}

