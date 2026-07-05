//
//  SparseSetTests.swift
//
//
//  slot 再利用時に stale な Entity ハンドルが別 entity を破壊しないことを検証する.
//  (issue #165)
//

import Testing
@testable import ECS

struct SparseSetTests {

    /// slot を 1 つ確保した空の SparseSet を返す.
    private func makeSet<T>(slots: Int, of type: T.Type = T.self) -> SparseSet<T> {
        var set = SparseSet<T>(sparse: [], dense: [], data: [])
        for _ in 0..<slots {
            set.allocate()
        }
        return set
    }

    // MARK: - contains

    @Test func containsRejectsStaleGeneration() {
        var set = makeSet(slots: 1, of: String.self)
        let gen0 = Entity(slot: 0, generation: 0)
        let gen1 = Entity(slot: 0, generation: 1)

        set.insert("gen0", withEntity: gen0)
        set.pop(entity: gen0)          // slot 0 を解放
        set.insert("gen1", withEntity: gen1) // slot 0 を再利用

        #expect(set.contains(gen1) == true)
        #expect(set.contains(gen0) == false) // stale ハンドルは false
    }

    @Test func containsRejectsOutOfRangeSlot() {
        let set = makeSet(slots: 1, of: String.self)
        // 確保していない slot を渡してもクラッシュせず false
        #expect(set.contains(Entity(slot: 5, generation: 0)) == false)
    }

    // MARK: - value

    @Test func valueRejectsStaleGeneration() {
        var set = makeSet(slots: 1, of: String.self)
        let gen0 = Entity(slot: 0, generation: 0)
        let gen1 = Entity(slot: 0, generation: 1)

        set.insert("gen0", withEntity: gen0)
        set.pop(entity: gen0)
        set.insert("gen1", withEntity: gen1)

        #expect(set.value(forEntity: gen1) == "gen1")
        #expect(set.value(forEntity: gen0) == nil)  // stale ハンドルは nil
    }

    @Test func valueRejectsOutOfRangeSlot() {
        let set = makeSet(slots: 1, of: String.self)
        #expect(set.value(forEntity: Entity(slot: 5, generation: 0)) == nil)
    }

    // MARK: - update

    @Test func updateIgnoresStaleGeneration() {
        var set = makeSet(slots: 1, of: String.self)
        let gen0 = Entity(slot: 0, generation: 0)
        let gen1 = Entity(slot: 0, generation: 1)

        set.insert("gen0", withEntity: gen0)
        set.pop(entity: gen0)
        set.insert("gen1", withEntity: gen1)

        // stale ハンドルでの update は no-op で, 再利用先の値を汚染しない
        set.update(forEntity: gen0) { $0 = "corrupted" }
        #expect(set.value(forEntity: gen1) == "gen1")

        set.update(forEntity: gen1) { $0 = "updated" }
        #expect(set.value(forEntity: gen1) == "updated")
    }

    @Test func updateIgnoresOutOfRangeSlot() {
        var set = makeSet(slots: 1, of: String.self)
        set.insert("live", withEntity: Entity(slot: 0, generation: 0))
        set.update(forEntity: Entity(slot: 5, generation: 0)) { $0 = "corrupted" }
        #expect(set.value(forEntity: Entity(slot: 0, generation: 0)) == "live")
    }

    // MARK: - pop

    @Test func popIsIdempotentForStaleHandle() {
        var set = makeSet(slots: 1, of: String.self)
        let gen0 = Entity(slot: 0, generation: 0)
        let gen1 = Entity(slot: 0, generation: 1)

        set.insert("gen0", withEntity: gen0)
        set.pop(entity: gen0)
        set.insert("gen1", withEntity: gen1)

        // stale ハンドルでの pop は no-op. 再利用先の gen1 は削除されない.
        set.pop(entity: gen0)
        #expect(set.contains(gen1) == true)
        #expect(set.value(forEntity: gen1) == "gen1")
    }

    @Test func popDoesNotCorruptOtherEntities() {
        var set = makeSet(slots: 3, of: String.self)
        let a = Entity(slot: 0, generation: 0)
        let b = Entity(slot: 1, generation: 0)
        let c = Entity(slot: 2, generation: 0)

        set.insert("a", withEntity: a)
        set.insert("b", withEntity: b)
        set.insert("c", withEntity: c)

        set.pop(entity: b)

        #expect(set.contains(b) == false)
        #expect(set.value(forEntity: a) == "a")
        #expect(set.value(forEntity: c) == "c")
    }
}
