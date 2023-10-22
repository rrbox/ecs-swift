//
//  SystemParameter.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

public protocol SystemParameter: AnyObject {
    static func register(to worldBuffer: WorldBuffer)
    static func getParameter(from worldBuffer: WorldBuffer) -> Self?
}

