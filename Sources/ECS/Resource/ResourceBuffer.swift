//
//  ResourceBuffer.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

enum ResourceStorage: WorldStorageType {}

protocol ResourceStorageElement: WorldStorageElement {}

extension AnyMap where Mode == ResourceStorage {
    mutating func push<T: ResourceStorageElement>(_ data: T) {
        self.body[ObjectIdentifier(T.self)] = Box(body: data)
    }

    mutating func pop<T: ResourceStorageElement>(_ type: T.Type) {
        self.body.removeValue(forKey: ObjectIdentifier(T.self))
    }

    func valueRef<T: ResourceStorageElement>(ofType type: T.Type) -> Box<T>? {
        guard let result = self.body[ObjectIdentifier(T.self)] else { return nil }
        return (result as! Box<T>)
    }
}

extension AnyMap<ResourceStorage> {
    mutating func addResource<T: ResourceProtocol>(_ resource: T) {
        push(Resource<T>(resource))
    }

    public func resource<T: ResourceProtocol>(ofType type: T.Type) -> Resource<T>? {
        valueRef(ofType: Resource<T>.self)?.body
    }
}
