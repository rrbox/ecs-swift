//
//  UpdateSystemProtocols.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public protocol SystemProtocol {
    associatedtype Parameter: SystemParameter
}

public protocol SystemProtocol2 {
    associatedtype P0: SystemParameter
    associatedtype P1: SystemParameter
}

public protocol SystemProtocol3 {
    associatedtype P0: SystemParameter
    associatedtype P1: SystemParameter
    associatedtype P2: SystemParameter
}

public protocol SystemProtocol4 {
    associatedtype P0: SystemParameter
    associatedtype P1: SystemParameter
    associatedtype P2: SystemParameter
    associatedtype P3: SystemParameter
}

public protocol SystemProtocol5 {
    associatedtype P0: SystemParameter
    associatedtype P1: SystemParameter
    associatedtype P2: SystemParameter
    associatedtype P3: SystemParameter
    associatedtype P4: SystemParameter
}
