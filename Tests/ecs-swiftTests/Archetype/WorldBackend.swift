//
//  WorldBackend.swift
//
//
//  Created by rrbox on 2026/07/09.
//

@testable import ECS

/// 新旧ストレージを切り替えて World を構築するテストヘルパです(タスク 7.1)。
///
/// `@Test(arguments: WorldBackend.allCases)` に渡すことで、同一テストを
/// legacy(現行 chunk 実装)と archetype(検証用新実装)の両バックエンドに流せます。
/// XCTest からも `for backend in WorldBackend.allCases { ... }` で利用できます。
enum WorldBackend: CaseIterable, CustomStringConvertible {
    /// 現行実装(chunk ベース)。`World()` と同じです。
    case legacy
    /// 新実装(`ExperimentalWorldOptions.archetypeStorage` ON)。
    case archetype

    /// このバックエンドの World を構築します。
    func makeWorld() -> World {
        switch self {
        case .legacy:
            return World()
        case .archetype:
            return World(experimentalOptions: [.archetypeStorage])
        }
    }

    /// テスト出力で引数を判別しやすくするための表示名です。
    var description: String {
        switch self {
        case .legacy:
            return "legacy"
        case .archetype:
            return "archetype"
        }
    }
}
