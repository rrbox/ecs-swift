//
//  SystemParameter.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

public protocol SystemParameter: AnyObject {
    static func register(to worldBuffer: BufferRef)
    static func getParameter(from worldBuffer: BufferRef) -> Self?
}

