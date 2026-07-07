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

        // MARK: Archetype バックエンド用の生成部品

        let accessTupleTypes = (0..<n).map {
            "ColumnAccess<C\($0)>"
        }.joined(separator: ", ")
        let requiredKeyAppends = (0..<n).map {
            "if !ColumnAccess<C\($0)>.isEntity { keys.append(ObjectIdentifier(C\($0).self)) }"
        }.joined(separator: "\n        ")
        let columnBindings = (0..<n).map {
            "case .column(let column\($0)) = match.access.\($0)"
        }.joined(separator: ",\n               ")
        let columnArgs = (0..<n).map {
            "&column\($0).data[row]"
        }.joined(separator: ", ")
        let rowValueDeclarations = (0..<n).map {
            "var value\($0) = match.access.\($0).value(at: row, in: match.archetype)"
        }.joined(separator: "\n                    ")
        let valueArgs = (0..<n).map {
            "&value\($0)"
        }.joined(separator: ", ")
        let rowValueWriteBacks = (0..<n).map {
            "match.access.\($0).setValue(value\($0), at: row)"
        }.joined(separator: "\n                    ")
        let matchRowValueDeclarations = (0..<n).map {
            "var value\($0) = match.access.\($0).value(at: match.row, in: match.archetype)"
        }.joined(separator: "\n            ")
        let matchRowValueWriteBacks = (0..<n).map {
            "match.access.\($0).setValue(value\($0), at: match.row)"
        }.joined(separator: "\n            ")
        let matchRowValues = (0..<n).map {
            "match.access.\($0).value(at: match.row, in: match.archetype)"
        }.joined(separator: ", ")
        let resolveBindings = (0..<n).map {
            "let access\($0) = ColumnAccess<C\($0)>.resolve(in: archetype, storage: storage)"
        }.joined(separator: ",\n              ")
        let accessValues = (0..<n).map {
            "access\($0)"
        }.joined(separator: ", ")

        return [
            """
            /// Archetype バックエンドでの 1 マッチ(マッチした Archetype と、解決済みのアクセス経路)です。
            ///
            /// `archetype` は `ArchetypeStorageRef` と同寿命の Archetype を参照するため
            /// `unowned` で保持します(`EntityLocation` と同じ設計方針)。
            struct ArchetypeMatch\(raw: n)<\(raw: genericArguments)> {
                unowned let archetype: Archetype
                let access: (\(raw: accessTupleTypes))
            }
            """,
            """
            final public class Query\(raw: n)<\(raw: genericArguments)>: Chunk, SystemParameter, QueryProtocol, ArchetypeObserver {
                public var components = SparseSet<(\(raw: refTypes))>(sparse: [], dense: [], data: [])

                // MARK: - Archetype バックエンド (archetype storage ON)

                /// マッチ済みの Archetype 一覧です。OFF の World では常に空です。
                var archetypeMatches = [ArchetypeMatch\(raw: n)<\(raw: valueTypes)>]()

                /// Archetype バックエンドのストレージです。OFF の World では nil のままです。
                ///
                /// `register(to:)` 時に一度だけ設定され、以降どちらのバックエンドで動くかは
                /// 変わりません(設計方針: バックエンドは register 時に確定)。
                /// ストレージ側(`observers`)が Query を強参照するため、循環を避けるために
                /// `unowned` で保持します(両者は World と同寿命です)。
                unowned var archetypeStorage: ArchetypeStorageRef?

                /// この Query が要求するコンポーネント型キーの一覧です。
                ///
                /// `Entity` ターゲットは要求に含めません(全 Archetype にマッチします。要件 2-6)。
                /// 重複型 assertion(要件 2-8)の検査対象です。
                static var requiredComponentTypeKeys: [ObjectIdentifier] {
                    var keys = [ObjectIdentifier]()
                    \(raw: requiredKeyAppends)
                    return keys
                }

                public override init() {}

                public func allocate() {
                    self.components.allocate()
                }

                public func insert(entityRecord: EntityRecordRef) {
                    guard \(raw: refDeclarationsFromRecord) else { return }
                    self.components.insert((\(raw: refs)), withEntity: entityRecord.entity)
                }

                public func remove(entity: Entity) {
                    guard self.components.contains(entity) else { return }
                    self.components.pop(entity: entity)
                }

                public override func spawn(entityRecord: EntityRecordRef) {
                    if entityRecord.entity.generation == 0 {
                        self.components.allocate()
                    }
                    self.insert(entityRecord: entityRecord)
                }

                override func despawn(entity: Entity) {
                    self.remove(entity: entity)
                }

                override func applyCurrentState(_ entityRecord: EntityRecordRef) {
                    guard \(raw: refDeclarationsFromRecord) else {
                        self.despawn(entity: entityRecord.entity)
                        return
                    }
                    guard !components.contains(entityRecord.entity) else { return }
                    self.components.insert((\(raw: refs)), withEntity: entityRecord.entity)
                }

                /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
                ///
                /// バックエンドは register 時に確定しているため, イテレーション経路にオプション分岐は
                /// ありません: OFF では `archetypeMatches` が, ON では `components` が常に空です.
                public func update(_ f: (\(raw: parameters)) -> ()) {
                    // chunk バックエンド (OFF)
                    self.components.data.forEach { components in
                        f(\(raw: componentRefs))
                    }
                    // Archetype バックエンド (ON)
                    for match in self.archetypeMatches {
                        if \(raw: columnBindings) {
                            // 全ターゲットが column の経路: `&data[i]` への直接アクセスのため,
                            // 要素ごとの動的ディスパッチはありません(要件 5-2)。
                            for row in match.archetype.entities.indices {
                                f(\(raw: columnArgs))
                            }
                        } else {
                            // Entity ターゲットを含む経路: Entity は `archetype.entities` から供給され,
                            // Entity への書き込みは破棄されます(要件 2-6)。
                            for row in match.archetype.entities.indices {
                                \(raw: rowValueDeclarations)
                                f(\(raw: valueArgs))
                                \(raw: rowValueWriteBacks)
                            }
                        }
                    }
                }

                public func update(_ entity: Entity, _ f: (\(raw: parameters)) -> ()) {
                    if let storage = self.archetypeStorage {
                        guard let match = self.archetypeRow(of: entity, in: storage) else { return }
                        // Entity ターゲットへの書き込みは破棄されます(要件 2-6)。
                        \(raw: matchRowValueDeclarations)
                        f(\(raw: valueArgs))
                        \(raw: matchRowValueWriteBacks)
                        return
                    }
                    guard let components = self.components.value(forEntity: entity) else { return }
                    f(\(raw: componentRefs))
                }

                public func components(forEntity entity: Entity) -> (\(raw: valueTypes))? {
                    if let storage = self.archetypeStorage {
                        guard let match = self.archetypeRow(of: entity, in: storage) else { return nil }
                        return (\(raw: matchRowValues))
                    }
                    guard let components = components.value(forEntity: entity) else { return nil }
                    return (\(raw: componentValuess))
                }

                public static func register(to worldStorage: WorldStorageRef) {
                    guard worldStorage.chunkStorageRef.chunk(ofType: Self.self) == nil else { return }
                    let queryRegistory = Self()
                    if let archetypeStorage = worldStorage.archetypeStorageRef {
                        // ON: system parameter として解決できるよう AnyMap への登録のみ行い,
                        // chunk broadcasts(ChunkEntityInterface)は購読しません。
                        worldStorage.chunkStorageRef.storage.push(queryRegistory)
                        queryRegistory.registerArchetypeBackend(archetypeStorage)
                    } else {
                        // OFF: 現行どおり AnyMap への登録 + chunk broadcasts の購読を行います。
                        worldStorage.chunkStorageRef.addChunk(queryRegistory)
                    }
                }

                public static func getParameter(from worldStorage: WorldStorageRef) -> Self? {
                    worldStorage.chunkStorageRef.chunk(ofType: Self.self)
                }

                // MARK: - Archetype バックエンド internals

                /// Archetype バックエンドを有効化します(register 時に一度だけ呼ばれます)。
                ///
                /// オブザーバ登録により以降の Archetype 生成を購読し, 既存の Archetype には
                /// 遡及マッチを行います。
                func registerArchetypeBackend(_ storage: ArchetypeStorageRef) {
                    let keys = Self.requiredComponentTypeKeys
                    assert(
                        Set(keys).count == keys.count,
                        "Query does not support duplicated component types."
                    )
                    self.archetypeStorage = storage
                    storage.observers.append(self)
                    for archetype in storage.archetypes {
                        self.matchArchetype(archetype, storage: storage)
                    }
                }

                /// Archetype とのマッチ判定を行い, マッチすれば `archetypeMatches` へ追加します。
                ///
                /// 判定は要求 typeID 集合 ⊆ archetype 型集合(要件 2-1, 2-2)で,
                /// 全ターゲットの `ColumnAccess.resolve` が成功することがそのまま判定を兼ねます
                /// (`Entity` ターゲットは常に解決されます。要件 2-6)。型集合ベースの判定のため,
                /// 型引数の順序はマッチ結果に影響しません(要件 2-3)。
                func matchArchetype(_ archetype: Archetype, storage: ArchetypeStorageRef) {
                    guard \(raw: resolveBindings)
                    else { return }
                    self.archetypeMatches.append(
                        ArchetypeMatch\(raw: n)(archetype: archetype, access: (\(raw: accessValues)))
                    )
                }

                /// entity の所在をマッチ済み Archetype から引き, アクセス経路と行番号を返します。
                ///
                /// entity が despawn 済み・世代不一致・この Query の対象型を持たない場合は nil です(要件 2-7)。
                private func archetypeRow(
                    of entity: Entity,
                    in storage: ArchetypeStorageRef
                ) -> (archetype: Archetype, access: (\(raw: accessTupleTypes)), row: Int)? {
                    guard let location = storage.location(of: entity),
                          let match = self.archetypeMatches.first(where: { $0.archetype === location.archetype })
                    else { return nil }
                    return (match.archetype, match.access, location.row)
                }

                /// 新しい Archetype の生成通知を受け, マッチ判定を行います(`ArchetypeObserver`)。
                ///
                /// - Important: `findOrCreate` は `applySpawnStaging` の drain 中にも呼ばれるため,
                ///   この実装では `spawnStagingQueue` に触れてはいけません(silent drop の原因になります)。
                func archetypeCreated(_ archetype: Archetype, storage: ArchetypeStorageRef) {
                    self.matchArchetype(archetype, storage: storage)
                }
            }
            """
        ]
    }
}
