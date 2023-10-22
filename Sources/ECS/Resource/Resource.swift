//
//  Resource.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

import Foundation

public protocol ResourceProtocol {
    
}

final public class Resource<T: ResourceProtocol>: BufferElement, SystemParameter {
    public var resource: T
    
    init(_ resource: T) {
        self.resource = resource
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func register(to worldBuffer: WorldBuffer) {
        
    }
    
    public static func getParameter(from worldBuffer: WorldBuffer) -> Resource<T>? {
        worldBuffer.resourceBuffer.resource(ofType: T.self)
    }
    
}
