//
//  StepOrder.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/06/08.
//

import XCTest

func ECSTAssertStepOrder(
    currentStep: Int,
    steps: inout [Int],
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let stepCount = steps.count
    var targetSteps = [Int](repeating: 0, count: stepCount)
    for i in 0 ... currentStep {
        targetSteps[i] += 1
    }
    steps[currentStep] += 1
    XCTAssertEqual(targetSteps, steps, file: file, line: line)
}
