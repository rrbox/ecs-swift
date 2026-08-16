//
//  ComponentTypeIDTests.swift
//
//
//  Created by rrbox on 2026/07/06.
//

@testable import ECS
import Testing

struct ComponentTypeIDTests {

    struct ComponentA {}
    struct ComponentB {}
    struct ComponentC {}

    @Test func sameTypeKeyReturnsSameID() {
        let registry = ComponentTypeRegistry()
        let first = registry.typeID(for: ObjectIdentifier(ComponentA.self))
        let second = registry.typeID(for: ObjectIdentifier(ComponentA.self))
        #expect(first == second)
    }

    @Test func differentTypeKeysReturnSequentialIDs() {
        let registry = ComponentTypeRegistry()
        let a = registry.typeID(for: ObjectIdentifier(ComponentA.self))
        let b = registry.typeID(for: ObjectIdentifier(ComponentB.self))
        let c = registry.typeID(for: ObjectIdentifier(ComponentC.self))
        #expect(a.value == 0)
        #expect(b.value == 1)
        #expect(c.value == 2)
        #expect(a != b)
        #expect(b != c)
    }

    @Test func independentRegistriesNumberIndependently() {
        let registry0 = ComponentTypeRegistry()
        let registry1 = ComponentTypeRegistry()
        // registry0 で先に別の型を採番しても、registry1 の採番には影響しない
        _ = registry0.typeID(for: ObjectIdentifier(ComponentA.self))
        _ = registry0.typeID(for: ObjectIdentifier(ComponentB.self))
        let idInRegistry0 = registry0.typeID(for: ObjectIdentifier(ComponentC.self))
        let idInRegistry1 = registry1.typeID(for: ObjectIdentifier(ComponentC.self))
        #expect(idInRegistry0.value == 2)
        #expect(idInRegistry1.value == 0)
    }

    @Test func comparableFollowsAssignmentOrder() {
        let registry = ComponentTypeRegistry()
        let a = registry.typeID(for: ObjectIdentifier(ComponentA.self))
        let b = registry.typeID(for: ObjectIdentifier(ComponentB.self))
        let c = registry.typeID(for: ObjectIdentifier(ComponentC.self))
        #expect(a < b)
        #expect(b < c)
        #expect([c, a, b].sorted() == [a, b, c])
    }

}
