//
//  SparseSetTests.swift
//  ECS_Swift
//
//  Created by rrbox on 2026/08/16.
//

import Testing
@testable import ECS

struct SparseSetTests {
    @Test func insertGrowsSparseArray() {
        var sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])

        sparseSet.insert("entity 3", withEntity: Entity(slot: 3, generation: 0))

        #expect(sparseSet.value(forEntity: Entity(slot: 3, generation: 0)) == "entity 3")
        #expect(sparseSet.value(forEntity: Entity(slot: 0, generation: 0)) == nil)
    }

    @Test func lookUpSlotOutOfSparseArray() {
        var sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])

        #expect(sparseSet.value(forEntity: Entity(slot: 0, generation: 0)) == nil)

        sparseSet.update(forEntity: Entity(slot: 0, generation: 0)) { _ in
            Issue.record("no entity is registered")
        }
    }
}
