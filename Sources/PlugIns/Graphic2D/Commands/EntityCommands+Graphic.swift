//
//  EntityCommands+Graphic.swift
//  
//
//  Created by rrbox on 2023/08/20.
//

import SpriteKit
import ECS

public struct Child: Component {}

public struct Parent: Component {}

struct _RemoveFromParentTransaction: Component {}

struct _RemoveAllChildrenTransaction: Component {}

struct _DespawnAllChildrenTransaction: Component {}

final class AddChild: EntityCommand {
    let child: Entity
    init(parent: Entity, child: Entity) {
        self.child = child
        super.init(entity: parent)
    }

    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        let childRecord = world.entityRecord(forEntity: self.child)!
        childRecord.addComponent(_AddChildNodeTransaction(parentEntity: self.entity))
        world.worldStorage.chunkStorageRef.pushUpdated(entityRecord: childRecord)
    }

}

final class RemoveAllChildren: EntityCommand {
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        record.addComponent(_RemoveAllChildrenTransaction())
    }
}

final class DespawnAllChildren: EntityCommand {
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        record.addComponent(_DespawnAllChildrenTransaction())
    }
}

final class RemoveFromParent: EntityCommand {
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        record.addComponent(_RemoveFromParentTransaction())
    }
}

public extension EntityCommands {
    /// Node hierarchy に存在しない SKNode を entity に紐づけて SceneResource の SKScene に配置します.
    @discardableResult func setGraphic<Node: SKNode>(
        _ nodeCreate: Nodes.NodeCreate<Node>
    ) -> Self {
        let node = nodeCreate.node
        nodeCreate.register(id(), node)
        self.pushCommand(SetGraphic(node: node, entity: id()))
        return self
            .addComponent(Graphic(node: node))
            .addComponent(Graphic<SKNode>(node: node))
            .addComponent(_AddChildNodeTransaction(parentEntity: nil))
    }

    /// SKScene にすでに追加されている SKNode を entity に紐付けます.
    @discardableResult func setGraphic<Node: SKNode>(
        _ nodeCreate: Nodes.NodeConnect<Node>
    ) -> Self {
        let node = nodeCreate.node
        nodeCreate.register(id(), node)
        self.pushCommand(SetGraphic(node: node, entity: id()))
        // _AddChildNodeTransaction を追加しない
        return self
            .addComponent(Graphic(node: node))
            .addComponent(Graphic<SKNode>(node: node))
    }

    @discardableResult func addChild(_ entity: Entity) -> Self {
        self.pushCommand(AddChild(parent: self.id(), child: entity))
        return self
    }

    @discardableResult func removeAllChildren() -> Self {
        self.pushCommand(RemoveAllChildren(entity: self.id()))
        return self
    }

    @discardableResult func removeFromParent() -> Self {
        self.pushCommand(RemoveFromParent(entity: self.id()))
        return self
    }
}

func removeChildIfDespawned(
    despawnEvent: EventReader<WillDespawnEvent>,
    hierarchy: Resource<Hierarchy>,
    commands: Commands
) {
    let hierarchy = hierarchy.resource
    for event in despawnEvent.events {
        let entity = event.despawnedEntity
        let parent = hierarchy.parent(of: entity)
        hierarchy.removeFromParent(entity)
        guard let parent, hierarchy.childrenIsEmpty(for: parent) else { continue }
        commands.entity(parent)
            .removeComponent(ofType: Parent.self)
    }
}

func despawnChildRecursive(
    despawnedEntity: Entity,
    hierarchy: Resource<Hierarchy>,
    commands: Commands
) {
    guard let children = hierarchy.resource.children(of: despawnedEntity) else { return }
    for child in children {
        despawnChildRecursive(
            despawnedEntity: child,
            hierarchy: hierarchy,
            commands: commands
        )
        commands.despawn(entity: child)
    }
}

func despawnChildIfParentDespawned(
    despawnedEntityEvent: EventReader<WillDespawnEvent>,
    hierarchy: Resource<Hierarchy>,
    commands: Commands
) {
    for event in despawnedEntityEvent.events {
        let despawnedEntity = event.despawnedEntity
        despawnChildRecursive(
            despawnedEntity: despawnedEntity,
            hierarchy: hierarchy,
            commands: commands
        )
        hierarchy.resource.removeRecursively(entity: despawnedEntity)
    }
}

// TODO: child を despawn するかどうか検討する
// - despawn する場合: post update で状態を反映させる方法を検討する
// - despawn しない場合: child から Child component を外す
func removeAllChildren(
    targetNodes: Filtered<Query2<Entity, Graphic<SKNode>>, And<With<Parent>, With<_RemoveAllChildrenTransaction>>>,
    hierarchy: Resource<Hierarchy>,
    commands: Commands
) {
    targetNodes.update { entity, node in
        node.nodeRef.removeAllChildren()
        commands
            .entity(entity)
            .removeComponent(ofType: Parent.self)
            .removeComponent(ofType: _RemoveAllChildrenTransaction.self)
        let children = hierarchy.resource.children(of: entity)
        children?.forEach { child in
            commands
                .entity(child)
                .removeComponent(ofType: Child.self)
        }
        hierarchy.resource.removeAllChildren(fromEntity: entity)
    }
}

@MainActor
func despawnAllChildren(
    targetNodes: Filtered<Query2<Entity, Graphic<SKNode>>, And<With<Parent>, With<_DespawnAllChildrenTransaction>>>,
    hierarchy: Resource<Hierarchy>,
    nodes: Resource<Nodes>,
    commands: Commands
) {
    targetNodes.update { entity, node in
        node.nodeRef.removeAllChildren()
        commands
            .entity(entity)
            .removeComponent(ofType: Parent.self)
            .removeComponent(ofType: _DespawnAllChildrenTransaction.self)

        let children = hierarchy.resource.children(of: entity)
        children?.forEach { child in
            commands.despawn(entity: child)
            // 防衛的に Nodes 経由で entity と SKNode の紐付けを削除する
            nodes.resource.removeNode(forEntity: child)
        }
        hierarchy.resource.removeAllChildren(fromEntity: entity)
    }
}
