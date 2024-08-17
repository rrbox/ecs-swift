//
//  SystemMacro.swift
//
//
//  Created by rrbox on 2024/06/30.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct SystemMacro: DeclarationMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        guard let intArg = argument.as(IntegerLiteralExprSyntax.self)?.literal else {
            fatalError("compiler bug: argument is not integer literal")
        }
        let n = Int(intArg.text)!

        let genericArguments = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("P\(i): SystemParameter, ")
        }.dropLast(2)
        let valueTypes = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("P\(i), ")
        }.dropLast(2)
        let parameterGetExpressions = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("P\(i).getParameter(from: worldStorageRef)!, ")
        }.dropLast(2)

        return [
            """
            class System\(raw: n)<\(raw: genericArguments)>: SystemExecute {
                let execute: (\(raw: valueTypes)) -> ()

               init(_ execute: @escaping (\(raw: valueTypes)) -> ()) {
                    self.execute = execute
                }

                override func execute(_ worldStorageRef: WorldStorageRef) {
                    self.execute(\(raw: parameterGetExpressions))
                }
            }
            """
        ]
    }
}

struct AddSystemMacroForWorld: DeclarationMacro {
    static func createAddSystemDeclaration(_ n: Int) -> DeclSyntax {
        let genericArguments = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("P\(i): SystemParameter, ")
        }.dropLast(2)
        let valueTypes = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("P\(i), ")
        }.dropLast(2)
        let registerExpressions = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("P\(i).register(to: self.worldStorage)\n")
        }.dropLast()

        let result: DeclSyntax = """
        @discardableResult func addSystem<\(raw: genericArguments)>(_ schedule: Schedule, _ system: @escaping (\(raw: valueTypes)) -> ()) -> World {
            self.worldStorage.systemStorage.addSystem(schedule, Systems.System\(raw: n)<\(raw: valueTypes)>(system))
            \(raw: registerExpressions)
            return self
        }
        """

        return result
    }

    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        guard let intArg = argument.as(IntegerLiteralExprSyntax.self)?.literal else {
            fatalError("compiler bug: argument is not integer literal")
        }
        let n = Int(intArg.text)!

        let declarations = (2...n).reduce(into: []) { partialResult, i in
            partialResult.append(createAddSystemDeclaration(i))
        }

        return declarations
    }
}

struct AddSystemMacroForEventResponderBuilder: DeclarationMacro {
    static func createAddSystemDeclaration(_ n: Int) -> DeclSyntax {
        let genericArguments = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("P\(i): SystemParameter, ")
        }.dropLast(2)
        let valueTypes = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("P\(i), ")
        }.dropLast(2)
        let registerExpressions = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("P\(i).register(to: self.worldStorage)\n")
        }.dropLast()

        let result: DeclSyntax = """
        @discardableResult func addSystem<\(raw: genericArguments)>(_ schedule: Schedule, _ system: @escaping (\(raw: valueTypes)) -> ()) -> EventResponderBuilder {
            if !self.systems.keys.contains(schedule) {
                self.systems[schedule] = []
            }
            self.systems[schedule]?.append(Systems.System\(raw: n)<\(raw: valueTypes)>(system))
            \(raw: registerExpressions)
            return self
        }
        """

        return result
    }

    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        guard let intArg = argument.as(IntegerLiteralExprSyntax.self)?.literal else {
            fatalError("compiler bug: argument is not integer literal")
        }
        let n = Int(intArg.text)!

        let declarations = (2...n).reduce(into: []) { partialResult, i in
            partialResult.append(createAddSystemDeclaration(i))
        }

        return declarations
    }
}
