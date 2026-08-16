//
//  ColumnAccessTests.swift
//
//
//  Created by rrbox on 2026/07/07.
//

@testable import ECS
import Testing

struct ColumnAccessTests {

    struct ComponentA: Component, Equatable {
        var value: Int
    }

    struct ComponentB: Component, Equatable {
        var name: String
    }

    /// テスト対象の Archetype には含まれないコンポーネント型です。
    struct ComponentC: Component, Equatable {
        var flag: Bool
    }

    // MARK: - Helpers

    /// [A, B] の 2 カラム構成の Archetype とストレージを生成し、2 行を投入します。
    static func makeStorageAndArchetypeAB() -> (storage: ArchetypeStorageRef, archetype: Archetype) {
        let storage = ArchetypeStorageRef()
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let idB = storage.typeID(for: ObjectIdentifier(ComponentB.self))
        let key = ArchetypeKey(sorting: [idA, idB])
        let archetype = storage.findOrCreate(
            key: key,
            prototypes: [Column<ComponentA>(), Column<ComponentB>()]
        )
        appendRow(
            to: archetype,
            entity: Entity(slot: 0, generation: 0),
            a: ComponentA(value: 10),
            b: ComponentB(name: "a")
        )
        appendRow(
            to: archetype,
            entity: Entity(slot: 1, generation: 0),
            a: ComponentA(value: 20),
            b: ComponentB(name: "b")
        )
        return (storage, archetype)
    }

    /// (entity, A, B) の 1 行を archetype に追加します。
    static func appendRow(to archetype: Archetype, entity: Entity, a: ComponentA, b: ComponentB) {
        archetype.appendRow(entity: entity) { columns in
            (columns[0] as! Column<ComponentA>).append(a)
            (columns[1] as! Column<ComponentB>).append(b)
        }
    }

    // MARK: - resolve

    @Test func resolvePresentComponentTypeReturnsColumnAndReadsValues() throws {
        let (storage, archetype) = Self.makeStorageAndArchetypeAB()

        let access = try #require(ColumnAccess<ComponentA>.resolve(in: archetype, storage: storage))

        // .column として解決され、保持カラムが公開される
        let column = try #require(access.columnRef)
        #expect(column.data == [ComponentA(value: 10), ComponentA(value: 20)])

        // 行単位の読み出しがカラムの実データと一致する
        #expect(access.value(at: 0, in: archetype) == ComponentA(value: 10))
        #expect(access.value(at: 1, in: archetype) == ComponentA(value: 20))
    }

    @Test func resolveSecondComponentTypeReturnsItsOwnColumn() throws {
        let (storage, archetype) = Self.makeStorageAndArchetypeAB()

        let access = try #require(ColumnAccess<ComponentB>.resolve(in: archetype, storage: storage))

        #expect(access.value(at: 0, in: archetype) == ComponentB(name: "a"))
        #expect(access.value(at: 1, in: archetype) == ComponentB(name: "b"))
    }

    @Test func resolveAbsentComponentTypeReturnsNil() {
        let (storage, archetype) = Self.makeStorageAndArchetypeAB()

        // Archetype に含まれない型は「マッチしない」ことを表す nil を返す
        #expect(ColumnAccess<ComponentC>.resolve(in: archetype, storage: storage) == nil)
    }

    @Test func resolveEntityTargetReturnsEntityCaseWithoutEntityColumn() throws {
        let (storage, archetype) = Self.makeStorageAndArchetypeAB()

        // Entity カラムは存在しないが、Entity ターゲットは .entity として解決される
        let access = try #require(ColumnAccess<Entity>.resolve(in: archetype, storage: storage))

        // .entity は保持カラムを持たない
        #expect(access.columnRef == nil)

        // 読み出しは archetype.entities から供給される
        #expect(access.value(at: 0, in: archetype) == Entity(slot: 0, generation: 0))
        #expect(access.value(at: 1, in: archetype) == Entity(slot: 1, generation: 0))
    }

    // MARK: - isEntity

    @Test func isEntityIsTrueOnlyForEntityTarget() {
        #expect(ColumnAccess<Entity>.isEntity)
        #expect(!ColumnAccess<ComponentA>.isEntity)
        #expect(!ColumnAccess<ComponentB>.isEntity)
    }

    // MARK: - write path

    @Test func setValueThroughColumnAccessMutatesUnderlyingColumnData() throws {
        let (storage, archetype) = Self.makeStorageAndArchetypeAB()
        let access = try #require(ColumnAccess<ComponentA>.resolve(in: archetype, storage: storage))

        access.setValue(ComponentA(value: 99), at: 1)

        // 保持カラムは Archetype 内カラムと同一実体であるため、書き込みが反映される
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        let column = try #require(archetype.column(of: idA) as? Column<ComponentA>)
        #expect(column.data == [ComponentA(value: 10), ComponentA(value: 99)])
        #expect(access.value(at: 1, in: archetype) == ComponentA(value: 99))
    }

    @Test func setValueOnEntityAccessIsDiscardedWithoutCrash() throws {
        let (storage, archetype) = Self.makeStorageAndArchetypeAB()
        let access = try #require(ColumnAccess<Entity>.resolve(in: archetype, storage: storage))

        // 現行 ImmutableRef の set no-op と同等: 書き込みは破棄され、クラッシュしない
        access.setValue(Entity(slot: 42, generation: 7), at: 0)

        #expect(archetype.entities == [
            Entity(slot: 0, generation: 0),
            Entity(slot: 1, generation: 0),
        ])
        #expect(access.value(at: 0, in: archetype) == Entity(slot: 0, generation: 0))
    }

}
