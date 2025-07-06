//
//  AdditionalStorage.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/07/03.
//

public protocol AdditionalStorageElement: WorldStorageElement {}

public enum AdditionalStorage: WorldStorageType {}

public extension AnyMap where Mode == AdditionalStorage {
     mutating func push<T: AdditionalStorageElement>(_ data: T) {
        self.body[ObjectIdentifier(T.self)] = Box(body: data)
    }

    mutating func pop<T: AdditionalStorageElement>(_ type: T.Type) {
        self.body.removeValue(forKey: ObjectIdentifier(T.self))
    }

    func valueRef<T: AdditionalStorageElement>(ofType type: T.Type) -> Box<T>? {
        guard let result = self.body[ObjectIdentifier(T.self)] else { return nil }
        return (result as! Box<T>)
    }
}

