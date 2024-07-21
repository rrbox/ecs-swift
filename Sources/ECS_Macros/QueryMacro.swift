//
//  QueryMacro.swift
//
//
//  Created by rrbox on 2024/06/23.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct QueryMacro: DeclarationMacro {
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
            partialResult.append("C\(i): QueryTarget, ")
        }.dropLast(2)
        let refTypes = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("Ref<C\(i)>, ")
        }.dropLast(2)
        let valueTypes = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("C\(i), ")
        }.dropLast(2)
        let parameters = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("inout C\(i), ")
        }.dropLast(2)
        let componentRefs = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("&components.\(i).value, ")
        }.dropLast(2)
        let componentValuess = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("components.\(i).value, ")
        }.dropLast(2)
        let refDeclarationsFromRecord = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("let c\(i) = entityRecord.ref(C\(i).self), ")
        }.dropLast(2)
        let refs = (0..<n).reduce(into: "") { partialResult, i in
            partialResult.append("c\(i), ")
        }.dropLast(2)
        
        return [
            """
            final public class Query\(raw: n)<\(raw: genericArguments)>: Chunk, SystemParameter, QueryProtocol {
                public var components = SparseSet<(\(raw: refTypes))>(sparse: [], dense: [], data: [])

                public override init() {}
                
                public func allocate() {
                    self.components.allocate()
                }
                
                public func insert(entity: Entity, entityRecord: EntityRecordRef) {
                    guard \(raw: refDeclarationsFromRecord) else { return }
                    self.components.insert((\(raw: refs)), withEntity: entity)
                }
                
                public override func spawn(entity: Entity, entityRecord: EntityRecordRef) {
                    if entity.generation == 0 {
                        self.components.allocate()
                    }
                    self.insert(entity: entity, entityRecord: entityRecord)
                }
                
                public override func despawn(entity: Entity) {
                    guard self.components.contains(entity) else { return }
                    self.components.pop(entity: entity)
                }
                
                override func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) {
                    guard \(raw: refDeclarationsFromRecord) else {
                        self.despawn(entity: entity)
                        return
                    }
                    guard !components.contains(entity) else { return }
                    self.components.insert((\(raw: refs)), withEntity: entity)
                }
                
                public func update(_ f: (\(raw: parameters)) -> ()) {
                    self.components.data.forEach { components in
                        f(\(raw: componentRefs))
                    }
                }
                
                public func update(_ entity: Entity, _ f: (\(raw: parameters)) -> ()) {
                    guard let components = self.components.value(forEntity: entity) else { return }
                    f(\(raw: componentRefs))
                }
                
                public func components(forEntity entity: Entity) -> (\(raw: valueTypes))? {
                    guard let components = components.value(forEntity: entity) else { return nil }
                    return (\(raw: componentValuess))
                }
                
                public static func register(to worldStorage: WorldStorageRef) {
                    guard worldStorage.chunkStorage.chunk(ofType: Self.self) == nil else { return }
                    let queryRegistory = Self()
                    worldStorage.chunkStorage.addChunk(queryRegistory)
                }
                
                public static func getParameter(from worldStorage: WorldStorageRef) -> Self? {
                    worldStorage.chunkStorage.chunk(ofType: Self.self)
                }
            }
            """
        ]
    }
}
