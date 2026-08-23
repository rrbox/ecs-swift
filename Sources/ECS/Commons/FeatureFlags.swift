//
//  FeatureFlags.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/09/27.
//

struct FeatureFlags: OptionSet {
    let rawValue: UInt8
    static let enabled: FeatureFlags = []

    static func isEnabled(_ flags: FeatureFlags) -> Bool {
        Self.enabled.contains(flags)
    }
}
