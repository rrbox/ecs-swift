//
//  MultiParametersSystem.swift
//
//
//  Created by rrbox on 2024/06/30.
//

import ECS_Macros

@freestanding(declaration, names: arbitrary)
macro System(_ n: Int) = #externalMacro(module: "ECS_Macros", type: "SystemMacro")

@freestanding(declaration, names: named(addSystem(_:_:)))
macro addSystemForWorld(_ n: Int) = #externalMacro(module: "ECS_Macros", type: "AddSystemMacroForWorld")

@freestanding(declaration, names: named(addSystem(_:_:)))
macro addSystemMacroForEventResponderBuilder(_ n: Int) = #externalMacro(module: "ECS_Macros", type: "AddSystemMacroForEventResponderBuilder")

enum Systems {
    #System(2)
    #System(3)
    #System(4)
    #System(5)
    #System(6)
    #System(7)
    #System(8)
    #System(9)
    #System(10)
    #System(11)
    #System(12)
    #System(13)
    #System(14)
    #System(15)
}

public extension World {
    #addSystemForWorld(15)
}

public extension EventResponderBuilder {
    #addSystemMacroForEventResponderBuilder(15)
}
