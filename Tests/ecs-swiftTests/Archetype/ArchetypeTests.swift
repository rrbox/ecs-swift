//
//  ArchetypeTests.swift
//
//
//  Created by rrbox on 2026/07/06.
//

@testable import ECS
import Testing

struct ArchetypeTests {

    struct ComponentA: Component, Equatable {
        let value: Int
    }

    struct ComponentB: Component, Equatable {
        let name: String
    }

    // MARK: - Helpers

    /// [A, B] の 2 カラム構成の Archetype と型 ID を生成します。
    static func makeArchetypeAB() -> (archetype: Archetype, idA: ComponentTypeID, idB: ComponentTypeID) {
        let registry = ComponentTypeRegistry()
        let idA = registry.typeID(for: ObjectIdentifier(ComponentA.self))
        let idB = registry.typeID(for: ObjectIdentifier(ComponentB.self))
        let key = ArchetypeKey(sorting: [idA, idB])
        let archetype = Archetype(key: key, columns: [Column<ComponentA>(), Column<ComponentB>()])
        return (archetype, idA, idB)
    }

    /// (entity, A, B) の 1 行を archetype に追加します。
    static func appendRow(to archetype: Archetype, entity: Entity, a: ComponentA, b: ComponentB) {
        archetype.appendRow(entity: entity) { columns in
            (columns[0] as! Column<ComponentA>).append(a)
            (columns[1] as! Column<ComponentB>).append(b)
        }
    }

    // MARK: - ArchetypeKey

    @Test func keyFromUnsortedInputEqualsKeyFromSortedInput() {
        let id0 = ComponentTypeID(value: 0)
        let id1 = ComponentTypeID(value: 1)
        let id2 = ComponentTypeID(value: 2)

        let sorted = ArchetypeKey(sorting: [id0, id1, id2])
        let unsorted = ArchetypeKey(sorting: [id2, id0, id1])

        #expect(sorted == unsorted)
        #expect(sorted.hashValue == unsorted.hashValue)
        #expect(unsorted.ids == [id0, id1, id2])
    }

    // MARK: - Archetype init / column(of:)

    @Test func columnOfReturnsParallelColumnForEachTypeID() throws {
        let (archetype, idA, idB) = Self.makeArchetypeAB()

        let columnA = try #require(archetype.column(of: idA))
        let columnB = try #require(archetype.column(of: idB))
        #expect(columnA is Column<ComponentA>)
        #expect(columnB is Column<ComponentB>)
        #expect(columnA !== columnB)
    }

    @Test func columnOfReturnsNilForAbsentTypeID() {
        let (archetype, idA, idB) = Self.makeArchetypeAB()

        let absent = ComponentTypeID(value: max(idA.value, idB.value) + 1)
        #expect(archetype.column(of: absent) == nil)
    }

    // MARK: - swapRemoveRow

    @Test func swapRemoveMiddleRowKeepsEntitiesAndColumnsInSyncAndReturnsFiller() throws {
        let (archetype, idA, idB) = Self.makeArchetypeAB()
        let e0 = Entity(slot: 0, generation: 0)
        let e1 = Entity(slot: 1, generation: 0)
        let e2 = Entity(slot: 2, generation: 0)
        Self.appendRow(to: archetype, entity: e0, a: ComponentA(value: 10), b: ComponentB(name: "a"))
        Self.appendRow(to: archetype, entity: e1, a: ComponentA(value: 20), b: ComponentB(name: "b"))
        Self.appendRow(to: archetype, entity: e2, a: ComponentA(value: 30), b: ComponentB(name: "c"))

        let filler = archetype.swapRemoveRow(1)

        // 末尾行(e2)が row 1 を埋めるために移動し、その entity が返る
        #expect(filler == e2)
        #expect(archetype.entities == [e0, e2])

        // 全カラムが entities と並行に swap-remove されている
        let columnA = try #require(archetype.column(of: idA) as? Column<ComponentA>)
        let columnB = try #require(archetype.column(of: idB) as? Column<ComponentB>)
        #expect(columnA.data == [ComponentA(value: 10), ComponentA(value: 30)])
        #expect(columnB.data == [ComponentB(name: "a"), ComponentB(name: "c")])
    }

    @Test func swapRemoveLastRowReturnsNil() throws {
        let (archetype, idA, idB) = Self.makeArchetypeAB()
        let e0 = Entity(slot: 0, generation: 0)
        let e1 = Entity(slot: 1, generation: 0)
        Self.appendRow(to: archetype, entity: e0, a: ComponentA(value: 1), b: ComponentB(name: "a"))
        Self.appendRow(to: archetype, entity: e1, a: ComponentA(value: 2), b: ComponentB(name: "b"))

        let filler = archetype.swapRemoveRow(1)

        // 末尾行の削除では穴埋めが発生しないため nil
        #expect(filler == nil)
        #expect(archetype.entities == [e0])
        let columnA = try #require(archetype.column(of: idA) as? Column<ComponentA>)
        let columnB = try #require(archetype.column(of: idB) as? Column<ComponentB>)
        #expect(columnA.data == [ComponentA(value: 1)])
        #expect(columnB.data == [ComponentB(name: "a")])
    }

    @Test func swapRemoveOnlyRowLeavesArchetypeEmpty() throws {
        let (archetype, idA, idB) = Self.makeArchetypeAB()
        Self.appendRow(
            to: archetype,
            entity: Entity(slot: 0, generation: 0),
            a: ComponentA(value: 1),
            b: ComponentB(name: "a")
        )

        let filler = archetype.swapRemoveRow(0)

        #expect(filler == nil)
        #expect(archetype.entities.isEmpty)
        let columnA = try #require(archetype.column(of: idA))
        let columnB = try #require(archetype.column(of: idB))
        #expect(columnA.count == 0)
        #expect(columnB.count == 0)
    }

}
