//
//  ChunkTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

#if DEBUG

import XCTest
@testable import ECS

class TestChunk: Chunk {
    var entities = [Entity: EntityRecordRef]()
    func spawn(entity: Entity, entityRecord: EntityRecordRef) async {
        self.entities[entity] = entityRecord
    }
    
    func despawn(entity: Entity) async {
        self.entities.removeValue(forKey: entity)
    }
    
    func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) async {
        
    }
}

class TestChunk_2: Chunk {
    var entities = [Entity: EntityRecordRef]()
    func spawn(entity: Entity, entityRecord: EntityRecordRef) {
        self.entities[entity] = entityRecord
    }
    
    func despawn(entity: Entity) {
        self.entities.removeValue(forKey: entity)
    }
    
    func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) async {
        
    }
}

final class ChunkTests: XCTestCase {
    func testInterface() async {
        let mockEntities = [Entity(), Entity(), Entity(), Entity(), Entity()]
        let world = World()
        
        // Spawn された entity を単に蓄積するだけの test 用の chunk です.
        let testChunk = TestChunk()
        let testChunk_2 = TestChunk_2()
        await world.worldStorage.chunkStorage.addChunk(testChunk)
        await world.worldStorage.chunkStorage.addChunk(testChunk_2)
        
        // chunk interface を介して chunk に entity を push します（回数: 5回）.
        for entity in mockEntities {
            await world.push(entity: entity, entityRecord: EntityRecordRef())
        }
        
        await world.worldStorage.chunkStorage.applyEntityQueue()
        
        XCTAssertEqual(testChunk.entities.count, 5)
        XCTAssertEqual(testChunk_2.entities.count, 5)
        
        // chunk interface を介して chunk から entity を削除します.
        for entity in mockEntities {
            await world.despawn(entity: entity)
        }
        
        XCTAssertEqual(testChunk.entities.count, 0)
        XCTAssertEqual(testChunk_2.entities.count, 0)
        
    }
}

#endif
