//
//  BundleMacro.swift
//
//
//  Created by rrbox on 2024/06/02.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct BundleMacro: ExtensionMacro {
    static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let membersAddition = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { i in
                i.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            }
            .reduce(into: "") { partialResult, identifier in
                partialResult.append("record.addComponent(self.\(identifier))\n")
            }
            .dropLast()

        let declSyntax: DeclSyntax =
            """
            extension \(type.trimmed): BundleProtocol {
                public func addComponent(forEntity record: EntityRecordRef) {
                    \(raw: membersAddition)
                }
            }
            """

        guard let extensionSyntax = declSyntax.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [
            extensionSyntax
        ]
    }
}
