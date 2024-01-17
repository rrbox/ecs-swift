//
//  QueryTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

#if DEBUG

import XCTest
@testable import ECS

extension Query {
    var count: Int {
        get async {
            return self.components.count
        }
    }
}
extension Query2 {
    var count: Int {
        get async {
            return self.components.count
        }
    }
}

extension Query3 {
    var count: Int {
        get async {
            return self.components.count
        }
    }
}

extension Query4 {
    var count: Int {
        get async {
            return self.components.count
        }
    }
}

extension Query5 {
    var count: Int {
        get async {
            return self.components.count
        }
    }
}


final class QueryTests: XCTestCase {
    func testQuery() async {
        let testQuery = Query<TestComponent>()
        let testQuery2 = Query2<TestComponent, TestComponent2>()
        let testQuery3 = Query3<TestComponent, TestComponent2, TestComponent3>()
        let testQuery4 = Query4<TestComponent, TestComponent2, TestComponent3, TestComponent4>()
        let testQuery5 = Query5<TestComponent, TestComponent2, TestComponent3, TestComponent4, TestComponent5>()
        
        let world = World()
        
        await world.worldStorage.chunkStorage.addChunk(testQuery)
        await world.worldStorage.chunkStorage.addChunk(testQuery2)
        await world.worldStorage.chunkStorage.addChunk(testQuery3)
        await world.worldStorage.chunkStorage.addChunk(testQuery4)
        await world.worldStorage.chunkStorage.addChunk(testQuery5)
        
        let commands = world.worldStorage.commandsStorage.commands()!
        
        let testEntity = await commands.spawn().addComponent(TestComponent(content: "test")).id()
        
        await world.applyCommands()
        
        let test = { () async in
            await (
                testQuery.count,
                testQuery2.count,
                testQuery3.count,
                testQuery4.count,
                testQuery5.count
            )
        }
        
        let test_0 = await test()
        
        XCTAssertEqual(test_0.0, 1)
        XCTAssertEqual(test_0.1, 0)
        XCTAssertEqual(test_0.2, 0)
        XCTAssertEqual(test_0.3, 0)
        XCTAssertEqual(test_0.4, 0)
        
        await commands.entity(testEntity)?.addComponent(TestComponent2(content: "test2"))
        
        await world.applyCommands()
        
        let test_1 = await test()
        
        XCTAssertEqual(test_1.0, 1)
        XCTAssertEqual(test_1.1, 1)
        XCTAssertEqual(test_1.2, 0)
        XCTAssertEqual(test_1.3, 0)
        XCTAssertEqual(test_1.4, 0)
        
        await commands.entity(testEntity)?.addComponent(TestComponent3(content: "test2"))
        
        await world.applyCommands()
        
        let test_2 = await test()
        
        XCTAssertEqual(test_2.0, 1)
        XCTAssertEqual(test_2.1, 1)
        XCTAssertEqual(test_2.2, 1)
        XCTAssertEqual(test_2.3, 0)
        XCTAssertEqual(test_2.4, 0)
        
        await commands.entity(testEntity)?.addComponent(TestComponent4(content: "test2"))
        
        await world.applyCommands()
        
        let test_3 = await test()
        
        XCTAssertEqual(test_3.0, 1)
        XCTAssertEqual(test_3.1, 1)
        XCTAssertEqual(test_3.2, 1)
        XCTAssertEqual(test_3.3, 1)
        XCTAssertEqual(test_3.4, 0)
        
        await commands.entity(testEntity)?.addComponent(TestComponent5(content: "test2"))
        
        await world.applyCommands()
        
        let test_4 = await test()
        
        XCTAssertEqual(test_4.0, 1)
        XCTAssertEqual(test_4.1, 1)
        XCTAssertEqual(test_4.2, 1)
        XCTAssertEqual(test_4.3, 1)
        XCTAssertEqual(test_4.4, 1)
        
        await commands.entity(testEntity)?.removeComponent(ofType: TestComponent.self)
        
        await world.applyCommands()
        
        let test_5 = await test()
        
        XCTAssertEqual(test_5.0, 0)
        XCTAssertEqual(test_5.1, 0)
        XCTAssertEqual(test_5.2, 0)
        XCTAssertEqual(test_5.3, 0)
        XCTAssertEqual(test_5.4, 0)
    }
    
}

#endif
