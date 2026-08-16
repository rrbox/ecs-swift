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

    @Test func containsInsertedEntity() {
        var sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])

        sparseSet.insert("entity 0", withEntity: Entity(slot: 0, generation: 0))

        #expect(sparseSet.contains(Entity(slot: 0, generation: 0)))
    }

    @Test func containsSlotOutOfSparseArray() {
        let sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])

        #expect(!sparseSet.contains(Entity(slot: 999, generation: 0)))
    }

    @Test func containsSlotHoldingNoEntity() {
        var sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])

        sparseSet.insert("entity 3", withEntity: Entity(slot: 3, generation: 0))

        #expect(!sparseSet.contains(Entity(slot: 0, generation: 0)))
    }

    @Test func containsStaleHandleAfterSlotReuse() {
        var sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])
        let despawned = Entity(slot: 0, generation: 0)
        let reusingSlot = Entity(slot: 0, generation: 1)

        sparseSet.insert("despawned", withEntity: despawned)
        sparseSet.pop(entity: despawned)
        sparseSet.insert("reusing slot", withEntity: reusingSlot)

        #expect(!sparseSet.contains(despawned))
        #expect(sparseSet.contains(reusingSlot))
    }

    @Test func lookUpStaleHandleAfterSlotReuse() {
        var sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])
        let despawned = Entity(slot: 0, generation: 0)
        let reusingSlot = Entity(slot: 0, generation: 1)

        sparseSet.insert("despawned", withEntity: despawned)
        sparseSet.pop(entity: despawned)
        sparseSet.insert("reusing slot", withEntity: reusingSlot)

        #expect(sparseSet.value(forEntity: despawned) == nil)
        #expect(sparseSet.value(forEntity: reusingSlot) == "reusing slot")
    }

    @Test func updateStaleHandleAfterSlotReuse() {
        var sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])
        let despawned = Entity(slot: 0, generation: 0)
        let reusingSlot = Entity(slot: 0, generation: 1)

        sparseSet.insert("despawned", withEntity: despawned)
        sparseSet.pop(entity: despawned)
        sparseSet.insert("reusing slot", withEntity: reusingSlot)

        sparseSet.update(forEntity: despawned) { _ in
            Issue.record("the despawned entity is no longer registered")
        }

        #expect(sparseSet.value(forEntity: reusingSlot) == "reusing slot")
    }

    @Test func popRemovesInsertedEntity() {
        var sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])
        let entity = Entity(slot: 0, generation: 0)

        sparseSet.insert("entity 0", withEntity: entity)
        sparseSet.pop(entity: entity)

        #expect(!sparseSet.contains(entity))
        #expect(sparseSet.value(forEntity: entity) == nil)
    }

    @Test func containsGuardedPopKeepsEntityReusingSlot() {
        var sparseSet = SparseSet<String>(sparse: [], dense: [], data: [])
        let despawned = Entity(slot: 0, generation: 0)
        let reusingSlot = Entity(slot: 0, generation: 1)

        sparseSet.insert("despawned", withEntity: despawned)
        sparseSet.pop(entity: despawned)
        sparseSet.insert("reusing slot", withEntity: reusingSlot)

        if sparseSet.contains(despawned) {
            sparseSet.pop(entity: despawned)
        }

        #expect(sparseSet.contains(reusingSlot))
        #expect(sparseSet.value(forEntity: reusingSlot) == "reusing slot")
    }
}
