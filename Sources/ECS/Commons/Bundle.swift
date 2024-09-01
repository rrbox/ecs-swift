//
//  Bundle.swift
//
//
//  Created by rrbox on 2024/06/02.
//

@attached(extension, names: named(addComponent(forEntity:)), conformances: BundleProtocol)
public macro Bundle() = #externalMacro(module: "ECS_Macros", type: "BundleMacro")

public protocol BundleProtocol {
    func addComponent(forEntity record: EntityRecordRef)
}
