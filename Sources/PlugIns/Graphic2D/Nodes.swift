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

    public struct NodeConnect<Node: SKNode> {
        let node: Node
        let register: (Entity, Node) -> Void
    }

    var store = [Entity: SKNode]()

    /// node hierarchy に存在しない SKNode を entity に紐付けます.
    public func create<Node: SKNode>(node: Node) -> NodeCreate<Node> {
        return .init(
            node: node,
            register: regiester(entity:node:)
        )
    }

    /// SKScene にすでに配置された SKNode を entity に紐付けます.
    public func connect<Node: SKNode>(
        nodeWithName name: String,
        as type: Node.Type,
        fromScene scene: SKScene
    ) -> NodeConnect<Node>? {
        guard let node = scene.childNode(withName: name) as? Node else {
            return nil
        }
        return .init(
            node: node,
            register: regiester(entity:node:)
        )
    }

    /// SKScene にすでに配置された SKNode を entity に紐付けます.
    public func connect<Node: SKNode>(
        nodeWithName name: String,
        as type: Node.Type,
        fromScene scene: SceneResource
    ) -> NodeConnect<Node>? {
        guard let node = scene.scene.childNode(withName: name) as? Node else {
            return nil
        }
        return .init(
            node: node,
            register: regiester(entity:node:)
        )
    }

    /// SKScene にすでに配置された SKNode を entity に紐付けます.
    public func connect<Node: SKNode>(
        node: Node
    ) -> NodeConnect<Node> {
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
