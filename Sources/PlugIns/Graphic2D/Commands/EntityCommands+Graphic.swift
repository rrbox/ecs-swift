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

class AddChild: EntityCommand {
    let child: Entity
    init(parent: Entity, child: Entity) {
        self.child = child
        super.init(entity: parent)
    }
    
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        let childRecord = world.entityRecord(forEntity: self.child)!
        guard let node = record.component(ofType: Graphic.self)?.nodeRef,
              let childNode = childRecord.component(ofType: Graphic.self)?.nodeRef else {
            fatalError("entity hierarchy error: entity don't have graphic.")
        }
        
        world.worldStorage.chunkStorage.pushUpdated(entity: self.child, entityRecord: childRecord)
        
        childNode.removeFromParent()
        node.addChild(childNode)
        
        // record の設定
        record.componentRef(ofType: Parent.self)?.value._children.insert(child)
        childRecord.addComponent(Child(_parent: self.entity))
        
    }
    
}

class RemoveAllChildren: EntityCommand {
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        let node = record.component(ofType: Graphic.self)!.nodeRef
        node.removeAllChildren()
        record.componentRef(ofType: Parent.self)?.value._children = []
        
        for child in record.componentRef(ofType: Parent.self)!.value.children {
            let childRecord = world.entityRecord(forEntity: child)!
            childRecord.removeComponent(ofType: Child.self)
            world.worldStorage.chunkStorage.pushUpdated(entity: child, entityRecord: childRecord)
        }
        
    }
}

class RemoveFromParent: EntityCommand {
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        let childNode = record.component(ofType: Graphic.self)!.nodeRef
        let parent = record.component(ofType: Child.self)!.parent
        let parentRecord = world.entityRecord(forEntity: parent)!
        let scene = world.worldStorage.resourceBuffer.resource(ofType: SceneResource.self)!.resource.scene
        childNode.move(toParent: scene)
        record.removeComponent(ofType: Child.self)
        
        parentRecord.componentRef(ofType: Parent.self)?.value._children.remove(self.entity)
        
//        world.worldStorage.chunkStorage.apply(record, forEntity: self.entity)
//        world.worldStorage.chunkStorage.apply(parentRecord, forEntity: parent)
    }
}

public protocol GraphicCommands {
    @discardableResult func setGraphic<Node: SKNode>(_ node: Node) -> Self
}

public extension EntityCommands {
    @discardableResult func setGraphic<Node: SKNode>(_ node: Node) -> Self {
        self.pushCommand(SetGraphic(node: node, entity: self.id()))
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

public func graphicPlugIn(world: World) {
    world
        .buildWillDespawnResponder { responder in
            responder
                .addSystem(.update, removeChildIfDespawned(despawnEvent:query:parentQuery:))
        }
}
