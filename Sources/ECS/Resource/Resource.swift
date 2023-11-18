//
//  Resource.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol ResourceProtocol {
    
}

final public class Resource<T: ResourceProtocol>: BufferElement, SystemParameter {
    public var resource: T
    
    init(_ resource: T) {
        self.resource = resource
    }
    
    public static func register(to worldBuffer: BufferRef) {
        
    }
    
    public static func getParameter(from worldBuffer: BufferRef) -> Resource<T>? {
        worldBuffer.resourceBuffer.resource(ofType: T.self)
    }
    
}
