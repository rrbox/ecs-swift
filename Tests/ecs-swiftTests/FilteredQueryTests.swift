//
//  FilteredQueryTests.swift
//  
//
//  Created by rrbox on 2024/01/16.
//

#if DEBUG

import XCTest
@testable import ECS



final class FilteredQueryTests: XCTestCase {
    func testFilteredQuery() async {
        let testQuery = Query<TestComponent>()
        let filtered1 = Filtered<Query<TestComponent>, With<TestComponent2>>()
        let filtered2 = Filtered<Query<TestComponent>, And<With<TestComponent2>, With<TestComponent3>>>()
        
        let world = World()
        
        await world.worldStorage.chunkStorage.addChunk(testQuery)
        await world.worldStorage.chunkStorage.addChunk(filtered1)
        await world.worldStorage.chunkStorage.addChunk(filtered2)
        
    }
}

#endif

