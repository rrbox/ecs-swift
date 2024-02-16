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
        guard let i = self.sparse[entity.slot] else { return nil }
        guard self.dense[i] == entity else { return nil }
        return self.data[i]
    }
    
    public mutating func update(forEntity entity: Entity, _ execute: (inout T) -> ()) {
        guard let i = self.sparse[entity.slot] else { return }
        guard self.dense[i].generation == entity.generation else { return }
        execute(&self.data[i])
    }
    
    public mutating func update(_ execute: (inout T) -> ()) {
        for i in self.data.indices {
            execute(&self.data[i])
        }
    }
    
    public mutating func allocate() {
        self.sparse.append(nil)
    }
    
    public mutating func insert(_ value: T, withEntity entity: Entity) {
        let denseIndex = self.dense.count
        self.sparse[entity.slot] = denseIndex
        self.dense.append(entity)
        self.data.append(value)
    }
    
    public mutating func pop(entity: Entity) {
        assert(entity.generation == self.dense[self.sparse[entity.slot]!].generation)
        let denseIndexLast = self.dense.count-1
        let removeIndex = self.sparse[entity.slot]!
        
        self.sparse[self.dense[denseIndexLast].slot] = removeIndex
        self.dense.swapAt(removeIndex, denseIndexLast)
        self.data.swapAt(removeIndex, denseIndexLast)
        self.data.removeLast()
        self.dense.removeLast()
    }
}
