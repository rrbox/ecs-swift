//
//  BundleTests.swift
//  
//
//  Created by rrbox on 2024/06/02.
//

@testable import ECS
import XCTest

final class BundleTests: XCTestCase {
    func testAddBundle() {
        var frags = [0]
        let world = World()
            .addSystem(.startUp) { (commands: Commands) in
                commands
                    .spawn()
                    .addBundle(TestBundle())
            }
            .addSystem(.update) { (query: Query5<TestComponent, TestComponent2, TestComponent3, TestComponent4, TestComponent5>) in
                frags[0] += 1
                XCTAssertEqual(query.components.data.count, 1)
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)

        XCTAssertEqual(frags, [1])
    }
}
