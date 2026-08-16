//
//  SparseSet.swift
//
//
//  Created by rrbox on 2024/02/13.
//

public struct SparseSet<T> {
    typealias DenseIndex = Int

    var sparse: [DenseIndex?]
    var dense: [Entity]
    var data: [T]

    public func value(forEntity entity: Entity) -> T? {
        guard self.sparse.indices.contains(entity.slot) else { return nil }
        guard let i = self.sparse[entity.slot] else { return nil }
        guard self.dense[i] == entity else { return nil }
        return self.data[i]
    }

    public mutating func update(forEntity entity: Entity, _ execute: (inout T) -> ()) {
        guard self.sparse.indices.contains(entity.slot) else { return }
        guard let i = self.sparse[entity.slot] else { return }
        guard self.dense[i] == entity else { return }
        execute(&self.data[i])
    }

    public mutating func update(_ execute: (inout T) -> ()) {
        for i in self.data.indices {
            execute(&self.data[i])
        }
    }

    public mutating func insert(_ value: T, withEntity entity: Entity) {
        while self.sparse.count <= entity.slot {
            self.sparse.append(nil)
        }

        let denseIndex = self.dense.count
        self.sparse[entity.slot] = denseIndex
        self.dense.append(entity)
        self.data.append(value)
    }

    public mutating func pop(entity: Entity) {
        guard self.contains(entity) else {
            assertionFailure("Attempted to remove a stale entity handle: \(entity). The entity has already been despawned or its slot has been reused.")
            return
        }
        let denseIndexLast = self.dense.count-1
        let removeIndex = self.sparse[entity.slot]!

        self.sparse[self.dense[denseIndexLast].slot] = removeIndex
        self.sparse[self.dense[removeIndex].slot] = nil
        self.dense.swapAt(removeIndex, denseIndexLast)
        self.data.swapAt(removeIndex, denseIndexLast)
        self.data.removeLast()
        self.dense.removeLast()
    }

    public func contains(_ entity: Entity) -> Bool {
        guard self.sparse.indices.contains(entity.slot) else { return false }
        guard let i = self.sparse[entity.slot] else { return false }
        guard self.dense.indices.contains(i) else { return false }
        return self.dense[i] == entity
    }
}
