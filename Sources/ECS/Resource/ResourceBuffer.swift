//
//  ResourceBuffer.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

final public class ResourceBuffer {
    let buffer: BufferRef
    init(buffer: BufferRef) {
        self.buffer = buffer
    }
    
    func addResource<T: ResourceProtocol>(_ resource: T) {
        self.buffer.map.push(Resource<T>(resource))
    }
    
    public func resource<T: ResourceProtocol>(ofType type: T.Type) -> Resource<T>? {
        self.buffer.map.valueRef(ofType: Resource<T>.self)?.body
    }
}

public extension BufferRef {
    var resourceBuffer: ResourceBuffer {
        ResourceBuffer(buffer: self)
    }
}
