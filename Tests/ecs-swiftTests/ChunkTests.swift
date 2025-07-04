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
    override func spawn(entityRecord: EntityRecordRef) {
        self.entities[entityRecord.entity] = entityRecord
    }

    override func despawn(entity: Entity) {
        self.entities.removeValue(forKey: entity)
    }
}

class TestChunk_2: Chunk {
    var entities = [Entity: EntityRecordRef]()
    override func spawn(entityRecord: EntityRecordRef) {
        self.entities[entityRecord.entity] = entityRecord
    }

    override func despawn(entity: Entity) {
        self.entities.removeValue(forKey: entity)
    }
}

final class ChunkTests: XCTestCase {
    func testInterface() {
        let mockEntities = [Entity(slot: 0, generation: 0), Entity(slot: 1, generation: 0), Entity(slot: 2, generation: 0), Entity(slot: 3, generation: 0), Entity(slot: 4, generation: 0)]
        let world = World()

        // Spawn された entity を単に蓄積するだけの test 用の chunk です.
        let testChunk = TestChunk()
        let testChunk_2 = TestChunk_2()
        world.worldStorage.chunkStorageRef.addChunk(testChunk)
        world.worldStorage.chunkStorageRef.addChunk(testChunk_2)

        // chunk interface を介して chunk に entity を push します（回数: 5回）.
        for entity in mockEntities {
            world.push(entityRecord: EntityRecordRef(entity: entity))
        }

        world.worldStorage.chunkStorageRef.applySpawnedEntityQueue()

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
