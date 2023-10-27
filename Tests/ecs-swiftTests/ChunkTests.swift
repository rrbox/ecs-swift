//
//  ChunkTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

import XCTest
@testable import ECS

class TestChunk: Chunk {
    var entities = [Entity: EntityRecordRef]()
    override func spawn(entity: Entity, entityRecord: EntityRecordRef) {
        self.entities[entity] = entityRecord
    }
    
    override func despawn(entity: Entity) {
        self.entities.removeValue(forKey: entity)
    }
}

class TestChunk_2: Chunk {
    var entities = [Entity: EntityRecordRef]()
    override func spawn(entity: Entity, entityRecord: EntityRecordRef) {
        self.entities[entity] = entityRecord
    }
    
    override func despawn(entity: Entity) {
        self.entities.removeValue(forKey: entity)
    }
}

final class ChunkTests: XCTestCase {
    func testInterface() {
        let mockEntities = [Entity(), Entity(), Entity(), Entity(), Entity()]
        let world = World()
        
        // Spawn された entity を単に蓄積するだけの test 用の chunk です.
        let testChunk = TestChunk()
        let testChunk_2 = TestChunk_2()
        world.worldBuffer.chunkStorage.addChunk(testChunk)
        world.worldBuffer.chunkStorage.addChunk(testChunk_2)
        
        // chunk interface を介して chunk に entity を push します（回数: 5回）.
        for entity in mockEntities {
            world.push(entity: entity, entityRecord: EntityRecordRef())
        }
        
        world.worldBuffer.chunkStorage.applyEntityQueue()
        
        XCTAssertEqual(testChunk.entities.count, 5)
        XCTAssertEqual(testChunk_2.entities.count, 5)
        
        // chunk interface を介して chunk から entity を削除します.
        for entity in mockEntities {
            world.despawn(entity: entity)
        }
        
        XCTAssertEqual(testChunk.entities.count, 0)
        XCTAssertEqual(testChunk_2.entities.count, 0)
        
    }
}
