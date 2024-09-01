//
//  MultiParamatersQuery.swift
//
//
//  Created by rrbox on 2024/06/23.
//

@freestanding(declaration, names: arbitrary)
macro Query(_ c: Int) = #externalMacro(module: "ECS_Macros", type: "QueryMacro")

public enum Queies {
    #Query(2)
    #Query(3)
    #Query(4)
    #Query(5)
    #Query(6)
    #Query(7)
    #Query(8)
    #Query(9)
    #Query(10)
}

public typealias Query2 = Queies.Query2
public typealias Query3 = Queies.Query3
public typealias Query4 = Queies.Query4
public typealias Query5 = Queies.Query5
public typealias Query6 = Queies.Query6
public typealias Query7 = Queies.Query7
public typealias Query8 = Queies.Query8
public typealias Query9 = Queies.Query9
public typealias Query10 = Queies.Query10
