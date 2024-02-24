//
//  WorldStorage.swift
//  
//
//  Created by rrbox on 2023/10/22.
//

enum WorldStorage {}

protocol WorldStorageElement {}

class Box<T: WorldStorageElement>: Item {
    var body: T
    
    init(body: T) {
        self.body = body
    }
}

extension AnyMap where Mode == WorldStorage {
    mutating func push<T: WorldStorageElement>(_ data: T) {
        self.body[ObjectIdentifier(T.self)] = Box(body: data)
    }
    
    mutating func pop<T: WorldStorageElement>(_ type: T.Type) {
        self.body.removeValue(forKey: ObjectIdentifier(T.self))
    }
    
    func valueRef<T: WorldStorageElement>(ofType type: T.Type) -> Box<T>? {
        guard let result = self.body[ObjectIdentifier(T.self)] else { return nil }
        return (result as! Box<T>)
    }
}
