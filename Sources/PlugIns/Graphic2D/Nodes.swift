//
//  Nodes.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/05/01.
//

import ECS
import SpriteKit

@MainActor
public final class Nodes: ResourceProtocol {
    public struct NodeCreate<Node: SKNode> {
        let node: Node
        let register: (Entity, Node) -> Void
    }

    var store = [Entity: SKNode]()

    public func create<Node: SKNode>(node: Node) -> NodeCreate<Node> {
        return .init(
            node: node,
            register: regiester(entity:node:)
        )
    }

    func regiester<Node: SKNode>(entity: Entity, node: Node) {
        store[entity] = node
    }

    func removeNode(forEntity entity: Entity) {
        store.removeValue(forKey: entity)
    }
}
