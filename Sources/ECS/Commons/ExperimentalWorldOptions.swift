//
//  ExperimentalWorldOptions.swift
//  ECS_Swift
//
//  Created by rrbox on 2026/07/06.
//

/// 検証用の実行時オプション。
///
/// 1ビルド内で World ごとに新旧実装を併存させるための内部機構であり、
/// ビルドパターン切り替え用の FeatureFlags とは役割を分ける。
/// 安定後に削除または昇格する。
struct ExperimentalWorldOptions: OptionSet {
    let rawValue: UInt8

    static let archetypeStorage = ExperimentalWorldOptions(rawValue: 1 << 0)
}
