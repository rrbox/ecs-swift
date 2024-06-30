//
//  ECSMacros.swift
//
//
//  Created by rrbox on 2024/06/02.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct ECSMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BundleMacro.self,
        QueryMacro.self,
        SystemMacro.self,
        AddSystemMacroForWorld.self,
        AddSystemMacroForEventResponderBuilder.self,
    ]
}
