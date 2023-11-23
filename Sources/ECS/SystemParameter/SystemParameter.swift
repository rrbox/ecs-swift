//
//  SystemParameter.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

public protocol SystemParameter: AnyObject {
    static func register(to worldStorage: WorldStorageRef)
    static func getParameter(from worldStorage: WorldStorageRef) -> Self?
}

