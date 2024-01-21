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
        
        world.worldStorage.chunkStorage.addChunk(testQueryAnd)
        world.worldStorage.chunkStorage.addChunk(testQueryOr)
        world.worldStorage.chunkStorage.addChunk(testQueryWithout)
        
        let commands = world.worldStorage.commandsStorage.commands()!
        
        let entity = commands.spawn()
            .addComponent(TestComponent(content: "c0"))
            .id()
        
        world.applyCommands()
        
        XCTAssertEqual(testQueryAnd.query.components.count, 0)
        XCTAssertEqual(testQueryOr.query.components.count, 0)
        XCTAssertEqual(testQueryWithout.query.components.count, 1)
        
        commands.entity(entity)?.addComponent(TestComponent2(content: "c1"))
        world.applyCommands()
        
        XCTAssertEqual(testQueryAnd.query.components.count, 0)
        XCTAssertEqual(testQueryOr.query.components.count, 1)
        XCTAssertEqual(testQueryWithout.query.components.count, 0)
        
        commands.entity(entity)?.addComponent(TestComponent3(content: "c2"))
        world.applyCommands()
        
        XCTAssertEqual(testQueryAnd.query.components.count, 1)
        XCTAssertEqual(testQueryOr.query.components.count, 1)
        XCTAssertEqual(testQueryWithout.query.components.count, 0)
        
        commands.entity(entity)?.removeComponent(ofType: TestComponent2.self)
        world.applyCommands()
        
        XCTAssertEqual(testQueryAnd.query.components.count, 0)
        XCTAssertEqual(testQueryOr.query.components.count, 1)
        XCTAssertEqual(testQueryWithout.query.components.count, 0)
        
        commands.entity(entity)?.removeComponent(ofType: TestComponent.self)
        world.applyCommands()
        
        XCTAssertEqual(testQueryAnd.query.components.count, 0)
        XCTAssertEqual(testQueryOr.query.components.count, 0)
        XCTAssertEqual(testQueryWithout.query.components.count, 0)
    }
}
