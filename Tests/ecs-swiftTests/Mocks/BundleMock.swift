//
//  BundleMock.swift
//
//
//  Created by rrbox on 2024/06/02.
//

import ECS

@Bundle
struct TestBundle {
    let test = TestComponent(content: "bundle_test")
    let test2 = TestComponent2(content: "bundle_test2")
    let test3 = TestComponent3(content: "bundle_test3")
    let test4 = TestComponent4(content: "bundle_test4")
    let test5 = TestComponent5(content: "bundle_test5")
}
