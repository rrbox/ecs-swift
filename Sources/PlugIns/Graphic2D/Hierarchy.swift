//
//  Hierarchy.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/09/30.
//

import ECS

public final class Hierarchy: ResourceProtocol {
    private(set) var childrenMap = [Entity: Set<Entity>]()
    private(set) var parentMap = [Entity: Entity]()

    // MARK: - public

    public func children(of parentEntity: Entity) -> Set<Entity>? {
        childrenMap[parentEntity]
    }

    public func parent(of childEntity: Entity) -> Entity? {
        parentMap[childEntity]
    }

    public func hasParentSlot(_ parent: Entity) -> Bool {
        return childrenMap.keys.contains(parent)
    }

    public func childrenIsEmpty(for parent: Entity) -> Bool {
        childrenMap[parent]?.isEmpty ?? true
    }

    // MARK: - internal

    func insertChild(_ childEntity: Entity, forParent parentEntity: Entity) {
        insertChildToSlot(childEntity: childEntity, parentEntity: parentEntity)
        setParentToSlot(parentEntity: parentEntity, childEntity: childEntity)
    }

    /// 指定した entity を hierarchy グラフから完全に削除します
    func removeRecursively(entity: Entity) {
        childrenMap[entity]?.forEach { removeRecursively(entity: $0) }
        childrenMap.removeValue(forKey: entity)
        guard let parent = parentMap.removeValue(forKey: entity) else { return }
        childrenMap[parent]?.remove(entity)
    }

    func removeAllChildren(fromEntity entity: Entity) {
        guard let children = childrenMap[entity] else { return }
        children.forEach { child in
            parentMap.removeValue(forKey: child)
        }
        childrenMap.removeValue(forKey: entity)
    }

    func removeFromParent(_ child: Entity) {
        guard let parent = parentMap.removeValue(forKey: child) else { return }
        childrenMap[parent]?.remove(child)
        if childrenMap[parent]?.count == 0 {
            childrenMap.removeValue(forKey: parent)
        }
    }

    // MARK: - private

    private func insertChildToSlot(childEntity: Entity, parentEntity: Entity) {
        childrenMap[parentEntity, default: []].insert(childEntity)
    }

    private func setParentToSlot(parentEntity: Entity, childEntity: Entity) {
        parentMap[childEntity] = parentEntity
    }
}
