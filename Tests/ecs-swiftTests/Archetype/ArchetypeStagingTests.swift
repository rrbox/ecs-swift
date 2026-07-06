//
//  ArchetypeStagingTests.swift
//
//
//  Created by rrbox on 2026/07/07.
//

@testable import ECS
import Testing

struct ArchetypeStagingTests {

    struct ValueComponent: Component, Equatable {
        let value: Int
    }

    struct NameComponent: Component, Equatable {
        let name: String
    }

    @Test func componentTypeKeyMatchesComponentType() {
        let ref = ComponentRef(value: ValueComponent(value: 42))
        let insertable: ArchetypeInsertable = ref
        #expect(insertable.componentTypeKey == ObjectIdentifier(ValueComponent.self))
        #expect(insertable.componentTypeKey != ObjectIdentifier(NameComponent.self))
    }

    @Test func makeColumnPrototypeReturnsEmptyColumnOfComponentType() {
        let ref = ComponentRef(value: ValueComponent(value: 42))
        let insertable: ArchetypeInsertable = ref
        let prototype = insertable.makeColumnPrototype()
        #expect(prototype.count == 0)
        #expect(prototype is Column<ValueComponent>)
    }

    @Test func appendValueAppendsCurrentValueToColumn() {
        let ref = ComponentRef(value: ValueComponent(value: 1))
        // 現在値(最後に書き込まれた値)が追加されることを確認します.
        ref.value = ValueComponent(value: 2)
        let insertable: ArchetypeInsertable = ref
        let column = Column<ValueComponent>()
        insertable.appendValue(to: column)
        insertable.appendValue(to: column)
        #expect(column.data == [ValueComponent(value: 2), ValueComponent(value: 2)])
    }

    @Test func enumerateInsertablesFromRecordSkipsEntityEntry() {
        // 旧 spawn 経路(Commands.spawn)と同じ手順で record を組み立てます.
        let entity = Entity(slot: 0, generation: 0)
        let record = EntityRecordRef(entity: entity)
        record.map.body[ObjectIdentifier(Entity.self)] = ImmutableRef(value: entity)
        record.addComponent(ValueComponent(value: 10))
        record.addComponent(NameComponent(name: "a"))

        let insertables = record.archetypeInsertables()

        // Entity エントリ(ImmutableRef)は適合しないため, コンポーネント 2 件のみが列挙されます.
        #expect(insertables.count == 2)
        let keys = Set(insertables.map { $0.componentTypeKey })
        #expect(keys == [
            ObjectIdentifier(ValueComponent.self),
            ObjectIdentifier(NameComponent.self),
        ])
        #expect(!keys.contains(ObjectIdentifier(Entity.self)))
    }

    @Test func enumeratedInsertablesCanBuildAndFillColumns() throws {
        let entity = Entity(slot: 1, generation: 0)
        let record = EntityRecordRef(entity: entity)
        record.map.body[ObjectIdentifier(Entity.self)] = ImmutableRef(value: entity)
        record.addComponent(ValueComponent(value: 7))

        let insertables = record.archetypeInsertables()
        #expect(insertables.count == 1)
        let insertable = try #require(insertables.first)

        let column = insertable.makeColumnPrototype()
        insertable.appendValue(to: column)
        #expect(column.count == 1)
        let typed = try #require(column as? Column<ValueComponent>)
        #expect(typed.data == [ValueComponent(value: 7)])
    }
}
