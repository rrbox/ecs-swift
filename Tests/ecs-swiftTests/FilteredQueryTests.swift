//
//  FilteredQueryTests.swift
//  
//
//  Created by rrbox on 2024/01/21.
//

import XCTest
@testable import ECS

final class FilteredQueryTests: XCTestCase {
    func testFilteredQuery() {
        let testQueryAnd = Filtered<Query<TestComponent>, And<With<TestComponent2>, With<TestComponent3>>>()
        let testQueryOr = Filtered<Query<TestComponent>, Or<With<TestComponent2>, With<TestComponent3>>>()
        let testQueryWithout = Filtered<Query<TestComponent>, And<WithOut<TestComponent2>, WithOut<TestComponent3>>>()

        let world = World()

        world.worldStorage.chunkStorageRef.addChunk(testQueryAnd)
        world.worldStorage.chunkStorageRef.addChunk(testQueryOr)
        world.worldStorage.chunkStorageRef.addChunk(testQueryWithout)

        let commands = world.worldStorage.commands

        let entity = commands.spawn()
            .addComponent(TestComponent(content: "c0"))
            .id()

        world.update(currentTime: 0)

        XCTAssertEqual(testQueryAnd.query.components.data.count, 0)
        XCTAssertEqual(testQueryOr.query.components.data.count, 0)
        XCTAssertEqual(testQueryWithout.query.components.data.count, 1)

        commands.entity(entity).addComponent(TestComponent2(content: "c1"))

        world.update(currentTime: 0)

        XCTAssertEqual(testQueryAnd.query.components.data.count, 0)
        XCTAssertEqual(testQueryOr.query.components.data.count, 1)
        XCTAssertEqual(testQueryWithout.query.components.data.count, 0)

        commands.entity(entity).addComponent(TestComponent3(content: "c2"))
        
        world.update(currentTime: 0)

        XCTAssertEqual(testQueryAnd.query.components.data.count, 1)
        XCTAssertEqual(testQueryOr.query.components.data.count, 1)
        XCTAssertEqual(testQueryWithout.query.components.data.count, 0)

        commands.entity(entity).removeComponent(ofType: TestComponent2.self)

        world.update(currentTime: 0)

        XCTAssertEqual(testQueryAnd.query.components.data.count, 0)
        XCTAssertEqual(testQueryOr.query.components.data.count, 1)
        XCTAssertEqual(testQueryWithout.query.components.data.count, 0)

        commands.entity(entity).removeComponent(ofType: TestComponent.self)

        world.update(currentTime: 0)

        XCTAssertEqual(testQueryAnd.query.components.data.count, 0)
        XCTAssertEqual(testQueryOr.query.components.data.count, 0)
        XCTAssertEqual(testQueryWithout.query.components.data.count, 0)
    }

    // TODO: - Filtered Query2 のテスト
}
