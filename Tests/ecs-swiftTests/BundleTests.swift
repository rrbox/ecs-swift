//
//  BundleTests.swift
//  
//
//  Created by rrbox on 2024/06/02.
//

@testable import ECS
import XCTest

final class BundleTests: XCTestCase {
    // タスク 7.2: 新旧両バックエンドで実行されます。
    // 対象 entity 数の検証は chunk 内部(components.data)ではなくイテレーション回数で行います
    // (新バックエンドでは chunk の SparseSet を使用しないため、挙動ベースの等価な検証に変更)。
    func testAddBundle() {
        for backend in WorldBackend.allCases {
            self.runAddBundle(backend: backend)
        }
    }

    private func runAddBundle(backend: WorldBackend) {
        var flags = [0]
        let world = backend.makeWorld()
            .addSystem(.startUp) { (commands: Commands) in
                commands
                    .spawn()
                    .addBundle(TestBundle())
            }
            .addSystem(.update) { (query: Query5<TestComponent, TestComponent2, TestComponent3, TestComponent4, TestComponent5>) in
                flags[0] += 1
                var matchedEntityCount = 0
                query.update { _, _, _, _, _ in
                    matchedEntityCount += 1
                }
                XCTAssertEqual(matchedEntityCount, 1)
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)

        XCTAssertEqual(flags, [1])
    }
}
