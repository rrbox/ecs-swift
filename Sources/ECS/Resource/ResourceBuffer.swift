//
//  ResourceBuffer.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

class ResourceBuffer {
    let buffer: Buffer
    init(buffer: Buffer) {
        self.buffer = buffer
    }
    
    func addResource<T: ResourceProtocol>(_ resource: T) {
        self.buffer.addComponent(Resource<T>(resource))
    }
    
    func resource<T: ResourceProtocol>(ofType type: T.Type) -> Resource<T>? {
        self.buffer.component(ofType: Resource<T>.self)
    }
}

extension WorldBuffer {
    var resourceBuffer: ResourceBuffer {
        ResourceBuffer(buffer: self)
    }
}
