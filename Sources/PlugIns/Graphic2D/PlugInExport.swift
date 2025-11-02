//
//  System.swift
//
//
//  Created by rrbox on 2024/05/06.
//

import SpriteKit
import ECS

/// entity heirarchy に入っていない entity に接続された SKNode を node hierarchy に追加します.
/// - Parameters:
///   - query: entity heirarchy に入っていない entity の query.
///   - graphics: 親 entity の SKNode を検索するための query.
///   - scene: 親 entity が指定されていない場合に配置先となる scene.
///   - commands: `_AddChildNodeTransaction` を削除するための commands.¥
func _addChildNodeSystem(
    query: Filtered<Query3<Entity, _AddChildNodeTransaction, Graphic<SKNode>>, WithOut<Child>>,
    graphics: Query<Graphic<SKNode>>,
    scene: Resource<SceneResource>,
    hierarchy: Resource<Hierarchy>,
    commands: Commands
) {
    query.update { childEntity, transaction, graphic in
        let childEntity = childEntity
        let graphic = graphic
        if let parentEntity = transaction.parentEntity {
            graphics.update(parentEntity) { parentNode in
                parentNode.nodeRef.addChild(graphic.nodeRef)
                if !hierarchy.resource.hasParentSlot(parentEntity) {
                    commands.entity(parentEntity)
                        .addComponent(Parent())
                }
                hierarchy.resource.insertChild(childEntity, forParent: parentEntity)
                commands.entity(childEntity)
                    .addComponent(Child())
            }
        } else {
            scene.resource.scene.addChild(graphic.nodeRef)
        }
        commands
            .entity(childEntity)
            .removeComponent(ofType: _AddChildNodeTransaction.self)
    }
}

/// 既に entity heirarchy に入っている entity に接続された SKNode の親ノードを変更します.
/// - Parameters:
///   - query: 既に entity heirarchy に入っている entity の query.
///   - graphics: 親 entity の SKNode を検索するための query.
///   - commands: `_AddChildNodeTransaction` を削除するための commands.
func _addChildNodeSystem(
    query: Filtered<Query3<Entity, _AddChildNodeTransaction, Graphic<SKNode>>, With<Child>>,
    graphics: Query<Graphic<SKNode>>,
    hierarchy: Resource<Hierarchy>,
    commands: Commands
) {
    query.update { childEntity, transaction, graphic in
        let childEntity = childEntity
        let graphic = graphic
        if let parentEntity = transaction.parentEntity {
            graphic.nodeRef.removeFromParent()
            graphics.update(parentEntity) { parentNode in
                parentNode.nodeRef.addChild(graphic.nodeRef)
                if !hierarchy.resource.hasParentSlot(parentEntity) {
                    commands.entity(parentEntity)
                        .addComponent(Parent())
                }
                hierarchy.resource.insertChild(childEntity, forParent: parentEntity)
                commands.entity(childEntity)
                    .addComponent(Child())
            }
        } else {
            fatalError("parent entity not found")
        }

        commands
            .entity(childEntity)
            .removeComponent(ofType: _AddChildNodeTransaction.self)
    }
}

@MainActor
func _removeFromParentSystem(
    query: Filtered<Query2<Entity, Graphic<SKNode>>, And<With<Child>, With<_RemoveFromParentTransaction>>>,
    nodes: Resource<Nodes>,
    hierarchy: Resource<Hierarchy>,
    commands: Commands
) {
    query.update { childEntity, childNode  in
        childNode.nodeRef.removeFromParent()
        nodes.resource.removeNode(forEntity: childEntity)
        commands.entity(childEntity)
            .removeComponent(ofType: Child.self)
            .removeComponent(ofType: _RemoveFromParentTransaction.self)

        guard let parent = hierarchy.resource.parent(of: childEntity) else { return }
        hierarchy.resource.removeFromParent(childEntity)
        if hierarchy.resource.childrenIsEmpty(for: parent) {
            commands.entity(parent)
                .removeComponent(ofType: Parent.self)
        }
    }
}

@MainActor
func _removeNodeIfDespawned(
    despawn: EventReader<WillDespawnEvent>,
    nodes: Resource<Nodes>
) {
    for event in despawn.events {
        let despawnedEntity = event.despawnedEntity
        nodes.resource
            .removeNode(forEntity: despawnedEntity)?
            .removeFromParent()
    }
}

// TODO: - Node 操作イベントのハンドリングは他のフェーズでも同様に行なわなくてもOK?
@MainActor
public func graphicPlugIn(world: World) {
    world
        .addResource(Nodes())
        .addResource(Hierarchy())
        .addSystem(.postStartUp, _addChildNodeSystem(query:graphics:hierarchy:commands:))
        .addSystem(.postStartUp, _addChildNodeSystem(query:graphics:scene:hierarchy:commands:))
        .addSystem(.postStartUp, _removeFromParentSystem(query:nodes:hierarchy:commands:))
        .addSystem(.postUpdate, _addChildNodeSystem(query:graphics:hierarchy:commands:))
        .addSystem(.postUpdate, _addChildNodeSystem(query:graphics:scene:hierarchy:commands:))
        .addSystem(.postUpdate, _removeFromParentSystem(query:nodes:hierarchy:commands:))

        .buildWillDespawnResponder { responder in
            responder
                .addSystem(.update, removeChildIfDespawned(despawnEvent:hierarchy:commands:))
                .addSystem(.update, despawnChildIfParentDespawned(despawnedEntityEvent:hierarchy:commands:))
                .addSystem(.update, _removeNodeIfDespawned(despawn:nodes:))
        }
}
