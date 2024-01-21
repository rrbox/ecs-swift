//
//  QueryTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

import XCTest
@testable import ECS

final class QueryTests: XCTestCase {
    func testQuery() {
        let testQuery = Query<TestComponent>()
        let testQuery2 = Query2<TestComponent, TestComponent2>()
        let testQuery3 = Query3<TestComponent, TestComponent2, TestComponent3>()
        let testQuery4 = Query4<TestComponent, TestComponent2, TestComponent3, TestComponent4>()
        let testQuery5 = Query5<TestComponent, TestComponent2, TestComponent3, TestComponent4, TestComponent5>()
        
        let testEntityQuery = Query<Entity>()
        let testEntityQuery2 = Query2<Entity, TestComponent>()
        let testEntityQuery3 = Query3<Entity, TestComponent, TestComponent2>()
        let testEntityQuery4 = Query4<Entity, TestComponent, TestComponent2, TestComponent3>()
        let testEntityQuery5 = Query5<Entity, TestComponent, TestComponent2, TestComponent3, TestComponent4>()
        
        let world = World()
        
        world.worldStorage.chunkStorage.addChunk(testQuery)
        world.worldStorage.chunkStorage.addChunk(testQuery2)
        world.worldStorage.chunkStorage.addChunk(testQuery3)
        world.worldStorage.chunkStorage.addChunk(testQuery4)
        world.worldStorage.chunkStorage.addChunk(testQuery5)
        
        world.worldStorage.chunkStorage.addChunk(testEntityQuery)
        world.worldStorage.chunkStorage.addChunk(testEntityQuery2)
        world.worldStorage.chunkStorage.addChunk(testEntityQuery3)
        world.worldStorage.chunkStorage.addChunk(testEntityQuery4)
        world.worldStorage.chunkStorage.addChunk(testEntityQuery5)
        
        let commands = world.worldStorage.commandsStorage.commands()!
        
        let testEntity = commands.spawn().addComponent(TestComponent(content: "test")).id()
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 1)
        XCTAssertEqual(testQuery2.components.count, 0)
        XCTAssertEqual(testQuery3.components.count, 0)
        XCTAssertEqual(testQuery4.components.count, 0)
        XCTAssertEqual(testQuery5.components.count, 0)
        
        XCTAssertEqual(testEntityQuery.components.count, 1)
        XCTAssertEqual(testEntityQuery2.components.count, 1)
        XCTAssertEqual(testEntityQuery3.components.count, 0)
        XCTAssertEqual(testEntityQuery4.components.count, 0)
        XCTAssertEqual(testEntityQuery5.components.count, 0)
        
        commands.entity(testEntity)?.addComponent(TestComponent2(content: "test2"))
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 1)
        XCTAssertEqual(testQuery2.components.count, 1)
        XCTAssertEqual(testQuery3.components.count, 0)
        XCTAssertEqual(testQuery4.components.count, 0)
        XCTAssertEqual(testQuery5.components.count, 0)
        
        XCTAssertEqual(testEntityQuery.components.count, 1)
        XCTAssertEqual(testEntityQuery2.components.count, 1)
        XCTAssertEqual(testEntityQuery3.components.count, 1)
        XCTAssertEqual(testEntityQuery4.components.count, 0)
        XCTAssertEqual(testEntityQuery5.components.count, 0)
        
        commands.entity(testEntity)?.addComponent(TestComponent3(content: "test2"))
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 1)
        XCTAssertEqual(testQuery2.components.count, 1)
        XCTAssertEqual(testQuery3.components.count, 1)
        XCTAssertEqual(testQuery4.components.count, 0)
        XCTAssertEqual(testQuery5.components.count, 0)
        
        XCTAssertEqual(testEntityQuery.components.count, 1)
        XCTAssertEqual(testEntityQuery2.components.count, 1)
        XCTAssertEqual(testEntityQuery3.components.count, 1)
        XCTAssertEqual(testEntityQuery4.components.count, 1)
        XCTAssertEqual(testEntityQuery5.components.count, 0)
        
        commands.entity(testEntity)?.addComponent(TestComponent4(content: "test2"))
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 1)
        XCTAssertEqual(testQuery2.components.count, 1)
        XCTAssertEqual(testQuery3.components.count, 1)
        XCTAssertEqual(testQuery4.components.count, 1)
        XCTAssertEqual(testQuery5.components.count, 0)
        
        XCTAssertEqual(testEntityQuery.components.count, 1)
        XCTAssertEqual(testEntityQuery2.components.count, 1)
        XCTAssertEqual(testEntityQuery3.components.count, 1)
        XCTAssertEqual(testEntityQuery4.components.count, 1)
        XCTAssertEqual(testEntityQuery5.components.count, 1)
        
        commands.entity(testEntity)?.addComponent(TestComponent5(content: "test2"))
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 1)
        XCTAssertEqual(testQuery2.components.count, 1)
        XCTAssertEqual(testQuery3.components.count, 1)
        XCTAssertEqual(testQuery4.components.count, 1)
        XCTAssertEqual(testQuery5.components.count, 1)
        
        commands.entity(testEntity)?.removeComponent(ofType: TestComponent.self)
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 0)
        XCTAssertEqual(testQuery2.components.count, 0)
        XCTAssertEqual(testQuery3.components.count, 0)
        XCTAssertEqual(testQuery4.components.count, 0)
        XCTAssertEqual(testQuery5.components.count, 0)
        
        XCTAssertEqual(testEntityQuery.components.count, 1)
        XCTAssertEqual(testEntityQuery2.components.count, 0)
        XCTAssertEqual(testEntityQuery3.components.count, 0)
        XCTAssertEqual(testEntityQuery4.components.count, 0)
        XCTAssertEqual(testEntityQuery5.components.count, 0)
    }
    
}
