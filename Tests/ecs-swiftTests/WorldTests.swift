//
//  WorldTests.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

import XCTest
import ECS

final class WorldTests: XCTestCase {
    // タスク 7.2: 新旧両バックエンドで実行されます。
    func testWorld() {
        for backend in WorldBackend.allCases {
            _ = backend.makeWorld()
        }
    }
}
