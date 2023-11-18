//
//  Resource.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol ResourceProtocol {
    
}

final public class Resource<T: ResourceProtocol>: WorldStorageElement, SystemParameter {
    public var resource: T
    
    init(_ resource: T) {
        self.resource = resource
    }
    
    public static func register(to worldStorage: WorldStorageRef) {
        
    }
    
    public static func getParameter(from worldStorage: WorldStorageRef) -> Resource<T>? {
        worldStorage.resourceBuffer.resource(ofType: T.self)
    }
    
}
