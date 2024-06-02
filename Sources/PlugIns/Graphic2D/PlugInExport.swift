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
///   - commands: `_AddChildNodeTransaction` を削除するための commands.
func _addChildNodeSystem(
    query: Filtered<Query3<Entity, _AddChildNodeTransaction, Graphic<SKNode>>, WithOut<Child>>,
    graphics: Query2<Graphic<SKNode>, Parent>,
    scene: Resource<SceneResource>,
    commands: Commands
) {
    query.update { childEntity, parent, graphic in
        if let parentEntity = parent.parentEntity {
            graphics.update(parentEntity) { parentNode, children in
                parentNode.nodeRef.addChild(graphic.nodeRef)
                children._children.insert(childEntity)
                commands.entity(childEntity)?
                    .addComponent(Child(_parent: parentEntity))
            }
        } else {
            scene.resource.scene.addChild(graphic.nodeRef)
        }
        
        commands
            .entity(childEntity)?
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
    graphics: Query2<Graphic<SKNode>, Parent>,
    commands: Commands
) {
    query.update { childEntity, parent, graphic in
        if let parentEntity = parent.parentEntity {
            graphic.nodeRef.removeFromParent()
            graphics.update(parentEntity) { parentNode, children in
                parentNode.nodeRef.addChild(graphic.nodeRef)
                children._children.insert(childEntity)
                commands.entity(childEntity)?
                    .addComponent(Child(_parent: parentEntity))
            }
        } else {
            fatalError("parent entity not found")
        }
        
        commands
            .entity(childEntity)?
            .removeComponent(ofType: _AddChildNodeTransaction.self)
    }
}


func _removeFromParentSystem(
    query: Filtered<Query3<Entity, Graphic<SKNode>, Child>, With<_RemoveFromParentTransaction>>,
    parents: Query<Parent>,
    commands: Commands
) {
    query.update { childEntity, childNode, child  in
        childNode.nodeRef.removeFromParent()
        commands.entity(childEntity)?
            .removeComponent(ofType: Child.self)
            .removeComponent(ofType: _RemoveFromParentTransaction.self)
        
        parents.update(child.parent) { parent in
            parent._children.remove(childEntity)
        }
    }
    
}

public func graphicPlugIn(world: World) {
    world
        .addSystem(.update, _addChildNodeSystem(query:graphics:scene:commands:))
        .addSystem(.update, _addChildNodeSystem(query:graphics:commands:))
        .addSystem(.update, _removeFromParentSystem(query:parents:commands:))
    
        .buildWillDespawnResponder { responder in
            responder
                .addSystem(.update, removeChildIfDespawned(despawnEvent:query:parentQuery:))
                .addSystem(.update, despawnChildIfParentDespawned(despawnedEntityEvent:children:commands:))
        }
}
