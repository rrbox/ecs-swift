//
//  SetUpSystemCommons.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol SetUpSystemParameter: SystemParameter {
    
}

public class SetUpExecute: SystemExecute {
    func setUp(worldBuffer: WorldBuffer) {}
}
