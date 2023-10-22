//
//  Buffer.swift
//  
//
//  Created by rrbox on 2023/10/22.
//

enum Buffer {}

protocol BufferElement {}

class Box<T: BufferElement>: Item {
    var body: T
    
    init(body: T) {
        self.body = body
    }
}

extension AnyMap where Mode == Buffer {
    mutating func push<T: BufferElement>(_ data: T) {
        self.body[ObjectIdentifier(T.self)] = Box(body: data)
    }
    
    mutating func pop<T: BufferElement>(_ type: T.Type) {
        self.body.removeValue(forKey: ObjectIdentifier(T.self))
    }
    
    mutating func valueRef<T: BufferElement>(ofType type: T.Type) -> Box<T>? {
        guard let result = self.body[ObjectIdentifier(T.self)] else { return nil }
        return (result as! Box<T>)
    }
}


