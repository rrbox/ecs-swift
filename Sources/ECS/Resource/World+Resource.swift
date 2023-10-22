//
//  World+Resource.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public extension World {
    /// world に resource を追加します.
    ///
    /// ``Commands/addResource(_:)`` とは異なり, resource はこのメソッドが実行されてすぐに追加されます.
    @discardableResult func addResource<T: ResourceProtocol>(_ resource: T) -> World {
        self.worldBuffer.resourceBuffer.addResource(resource)
        return self
    }
}
