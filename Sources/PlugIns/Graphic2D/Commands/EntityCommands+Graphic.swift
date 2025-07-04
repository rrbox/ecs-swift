//
//  EntityCommands+Graphic.swift
//  
//
//  Created by rrbox on 2023/08/20.
//

import SpriteKit
import ECS

public struct Child: Component {
    var _parent: Entity
    public var parent: Entity {
        self._parent
    }
}

public struct Parent: Component {
    var _children: Set<Entity>
    public var children: Set<Entity> {
        self._children
    }
}

struct _RemoveFromParentTransaction: Component {

}

final class AddChild: EntityCommand {
    let child: Entity
    init(parent: Entity, child: Entity) {
        self.child = child
        super.init(entity: parent)
    }

    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        let childRecord = world.entityRecord(forEntity: self.child)!
        childRecord.addComponent(_AddChildNodeTransaction(parentEntity: self.entity))
    }

}

final class RemoveAllChildren: EntityCommand {
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        let node = record.component(ofType: Graphic.self)!.nodeRef
        node.removeAllChildren()
        record.componentRef(ofType: Parent.self)?.value._children = []

        for child in record.componentRef(ofType: Parent.self)!.value.children {
            let childRecord = world.entityRecord(forEntity: child)!
            childRecord.removeComponent(ofType: Child.self)
            world.worldStorage.chunkStorageRef.pushUpdated(entityRecord: childRecord)
        }

    }
}

final class RemoveFromParent: EntityCommand {
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        record.addComponent(_RemoveFromParentTransaction())
    }
}

public extension EntityCommands {
    @discardableResult func setGraphic<Node: SKNode>(_ nodeCreate: Nodes.NodeCreate<Node>) -> Self {
        let node = nodeCreate.node
        nodeCreate.register(id(), node)
        self.pushCommand(SetGraphic(node: node, entity: id()))
        return self.addComponent(Graphic(node: node)).addComponent(Graphic<SKNode>(node: node))
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
    query: Query<Child>,
    parentQuery: Query<Parent>
) {
    let entity = despawnEvent.value.despawnedEntity
    guard let parent = query.components(forEntity: entity)?.parent else { return }
    parentQuery.update(parent) { p in
        p._children.remove(entity)
    }
}

// これが実行される時点ですでに parentEntity から despawn した parent が消えている.
func despawnChildRecursive(
    despawnedEntity: Entity,
    children: Query2<Entity, Child>,
    commands: Commands
) {
    children.update { entity, child in
        if child.parent == despawnedEntity {
            despawnChildRecursive(despawnedEntity: entity, children: children, commands: commands)
            commands.despawn(entity: entity)
        }
    }
}

// これが実行される時点ですでに parentEntity から despawn した parent が消えている.
func despawnChildIfParentDespawned(
    despawnedEntityEvent: EventReader<WillDespawnEvent>,
    children: Query2<Entity, Child>,
    commands: Commands
) {
    // despawn した entity と自分の親が一致する子を despawn する.
    despawnChildRecursive(despawnedEntity: despawnedEntityEvent.value.despawnedEntity,
                          children: children,
                          commands: commands)
}
