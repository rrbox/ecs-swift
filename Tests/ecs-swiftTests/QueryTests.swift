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
        
        let world = World()
        
        world.worldBuffer.chunkBuffer.addChunk(testQuery)
        world.worldBuffer.chunkBuffer.addChunk(testQuery2)
        world.worldBuffer.chunkBuffer.addChunk(testQuery3)
        world.worldBuffer.chunkBuffer.addChunk(testQuery4)
        world.worldBuffer.chunkBuffer.addChunk(testQuery5)
        
        let commands = world.worldBuffer.commandsBuffer.commands()!
        
        let testEntity = commands.spawn().addComponent(TestComponent(content: "test")).id()
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 1)
        XCTAssertEqual(testQuery2.components.count, 0)
        XCTAssertEqual(testQuery3.components.count, 0)
        XCTAssertEqual(testQuery4.components.count, 0)
        XCTAssertEqual(testQuery5.components.count, 0)
        
        commands.entity(testEntity)?.addComponent(TestComponent2(content: "test2"))
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 1)
        XCTAssertEqual(testQuery2.components.count, 1)
        XCTAssertEqual(testQuery3.components.count, 0)
        XCTAssertEqual(testQuery4.components.count, 0)
        XCTAssertEqual(testQuery5.components.count, 0)
        
        commands.entity(testEntity)?.addComponent(TestComponent3(content: "test2"))
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 1)
        XCTAssertEqual(testQuery2.components.count, 1)
        XCTAssertEqual(testQuery3.components.count, 1)
        XCTAssertEqual(testQuery4.components.count, 0)
        XCTAssertEqual(testQuery5.components.count, 0)
        
        commands.entity(testEntity)?.addComponent(TestComponent4(content: "test2"))
        
        world.applyCommands()
        
        XCTAssertEqual(testQuery.components.count, 1)
        XCTAssertEqual(testQuery2.components.count, 1)
        XCTAssertEqual(testQuery3.components.count, 1)
        XCTAssertEqual(testQuery4.components.count, 1)
        XCTAssertEqual(testQuery5.components.count, 0)
        
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
    }
    
}
