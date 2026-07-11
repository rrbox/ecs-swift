//
//  ArchetypeBenchmarks.swift
//
//
//  Created by rrbox on 2026/07/11.
//

import Foundation
@testable import ECS
import Testing

// MARK: - 実行ゲート

/// ベンチマークの実行可否です。
///
/// CI(plain `swift test`)ではこのターゲットもビルド・実行対象になるため、
/// 環境変数でゲートして CI では skip(即 return)します(design.md「CI には含めない」)。
/// 手動実行時のみ以下で計測します:
///
/// ```sh
/// RUN_BENCHMARKS=1 swift test -c release --filter Benchmarks
/// ```
private var benchmarksEnabled: Bool {
    ProcessInfo.processInfo.environment["RUN_BENCHMARKS"] == "1"
}

// MARK: - 計測パラメータ

/// 比較対象の entity 数です(design.md: 10^3 / 10^4 / 10^5)。
private let entityCounts = [1_000, 10_000, 100_000]

/// 1 計測点あたりの実行回数です。中央値を採用します(tasks.md 8.3: 複数回実行の中央値)。
private let benchmarkRuns = 5

// MARK: - 計測ヘルパ

/// `body` の実行時間をミリ秒で返します(`ContinuousClock` による手動計測、
/// design.md「Benchmarks ターゲット」)。
///
/// `ContinuousClock` は macOS 13+ / iOS 16+ のため `#available` で分岐します。
/// ベンチマークは手動実行専用であり、旧 OS では実行しない前提です。
private func measureMilliseconds(_ body: () -> Void) -> Double {
    if #available(macOS 13.0, iOS 16.0, *) {
        let duration = ContinuousClock().measure(body)
        let (seconds, attoseconds) = duration.components
        return Double(seconds) * 1_000 + Double(attoseconds) / 1e15
    } else {
        fatalError("Benchmarks require macOS 13.0+ / iOS 16.0+ (ContinuousClock).")
    }
}

/// ミリ秒値の表示用フォーマットです。
private func formatMilliseconds(_ value: Double) -> String {
    String(format: "%.3f", value)
}

/// `run`(1 回分の計測。戻り値はミリ秒)を `runs` 回実行し、中央値を print して返します。
///
/// world の構築などのセットアップは `run` の内部で行い、計測区間
/// (`measureMilliseconds`)から除外します。
private func measureMedian(label: String, runs: Int = benchmarkRuns, of run: () -> Double) -> Double {
    precondition(runs > 0, "runs must be positive.")
    var samples = [Double]()
    samples.reserveCapacity(runs)
    for _ in 0..<runs {
        samples.append(run())
    }
    samples.sort()
    let median = samples[samples.count / 2]
    print("\(label): median=\(formatMilliseconds(median))ms (runs=\(runs))")
    return median
}

/// 同一シナリオを新旧両バックエンドで計測し、比較行を print します。
///
/// 出力例: `scenario1 iteration N=1000 frames=100 legacy=1.234ms archetype=0.987ms`
private func compareBackends(scenarioLabel: String, run: (Backend) -> Double) {
    var results = [String]()
    for backend in Backend.allCases {
        let median = measureMedian(label: "\(scenarioLabel) \(backend)") {
            run(backend)
        }
        results.append("\(backend)=\(formatMilliseconds(median))ms")
    }
    print("\(scenarioLabel) \(results.joined(separator: " "))")
}

// MARK: - バックエンド切り替えヘルパ

/// 新旧ストレージを切り替えて World を構築するベンチマーク用ヘルパです。
///
/// `Tests/ecs-swiftTests/Archetype/WorldBackend.swift` の最小版の複製です
/// (testTarget 間は import できないため、Benchmarks ターゲットに重複定義しています)。
private enum Backend: CaseIterable, CustomStringConvertible {
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

    /// 出力で判別しやすくするための表示名です。
    var description: String {
        switch self {
        case .legacy:
            return "legacy"
        case .archetype:
            return "archetype"
        }
    }
}

// MARK: - ベンチマーク用 component

/// シナリオ1(イテレーション)用の 3 型です。
private struct Position: Component {
    var x: Double
    var y: Double
}

private struct Velocity: Component {
    var dx: Double
    var dy: Double
}

private struct Health: Component {
    var value: Int
}

/// シナリオ2・3 で spawn する entity が持つ component です。
private struct Payload: Component {
    var value: Int
}

// MARK: - シナリオ2用マーカー component(k 個の相異なる Query 型)

/// 登録 Query 数 k = 1, 10, 50 を作るためのマーカー component 群です。
///
/// `Query<C>` は component 型ごとに別の Query 型になるため、k 個の相異なる Query を
/// 登録するには k 個の相異なる型が必要です。ジェネリクスやマクロで 50 型を量産する
/// 仕組みは持たないため、Spike の割り切りとして 50 個をリテラル定義します。
private enum Markers {
    struct M1: Component {}
    struct M2: Component {}
    struct M3: Component {}
    struct M4: Component {}
    struct M5: Component {}
    struct M6: Component {}
    struct M7: Component {}
    struct M8: Component {}
    struct M9: Component {}
    struct M10: Component {}
    struct M11: Component {}
    struct M12: Component {}
    struct M13: Component {}
    struct M14: Component {}
    struct M15: Component {}
    struct M16: Component {}
    struct M17: Component {}
    struct M18: Component {}
    struct M19: Component {}
    struct M20: Component {}
    struct M21: Component {}
    struct M22: Component {}
    struct M23: Component {}
    struct M24: Component {}
    struct M25: Component {}
    struct M26: Component {}
    struct M27: Component {}
    struct M28: Component {}
    struct M29: Component {}
    struct M30: Component {}
    struct M31: Component {}
    struct M32: Component {}
    struct M33: Component {}
    struct M34: Component {}
    struct M35: Component {}
    struct M36: Component {}
    struct M37: Component {}
    struct M38: Component {}
    struct M39: Component {}
    struct M40: Component {}
    struct M41: Component {}
    struct M42: Component {}
    struct M43: Component {}
    struct M44: Component {}
    struct M45: Component {}
    struct M46: Component {}
    struct M47: Component {}
    struct M48: Component {}
    struct M49: Component {}
    struct M50: Component {}
}

/// マーカー Query を 1 つ登録する処理の一覧です(先頭 k 個を使用します)。
///
/// system parameter として `Query<Mi>` を持つ空 system を追加することで、
/// `addSystem` 時の `register(to:)` により Query が World に登録されます。
private let markerQueryRegistrations: [(World) -> Void] = [
    { $0.addSystem(.update) { (_: Query<Markers.M1>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M2>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M3>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M4>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M5>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M6>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M7>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M8>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M9>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M10>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M11>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M12>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M13>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M14>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M15>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M16>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M17>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M18>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M19>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M20>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M21>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M22>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M23>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M24>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M25>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M26>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M27>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M28>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M29>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M30>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M31>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M32>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M33>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M34>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M35>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M36>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M37>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M38>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M39>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M40>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M41>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M42>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M43>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M44>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M45>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M46>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M47>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M48>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M49>) in } },
    { $0.addSystem(.update) { (_: Query<Markers.M50>) in } },
]

// MARK: - ベンチマーク本体

/// 新旧バックエンド比較ベンチマークです(タスク 8.1, 8.2 / 要件 5-1〜5-5, 3-4)。
///
/// ## 実行方法
///
/// CI では各テスト冒頭の環境変数ゲートにより skip され(即 return して pass)、
/// 手動実行時のみ以下で計測します(design.md「CI には含めない」の運用):
///
/// ```sh
/// RUN_BENCHMARKS=1 swift test -c release --filter Benchmarks
/// ```
///
/// ## 計測方式
///
/// - `ContinuousClock` による手動計測(セットアップは計測区間外)
/// - 各計測点は `benchmarkRuns` 回実行の中央値(tasks.md 8.3)
/// - 新旧を同一シナリオ・同一 entity 数(10^3 / 10^4 / 10^5)で比較し、
///   `scenarioX ... legacy=...ms archetype=...ms` 形式で出力します
struct ArchetypeBenchmarks {

    // MARK: シナリオ1: イテレーション (要件 5-2, 5-3)

    /// 3 型 component × N entities を `Query3` で全更新する update ループ
    /// (100 フレーム)を計測します。
    ///
    /// 計測対象は `world.update(currentTime:)` × 100 フレームのループ全体で、
    /// spawn の flush(準備フレーム)は計測区間外です。フレーム数は N によらず
    /// 100 で固定し、新旧で完全に対称な条件とします。
    @Test func scenario1Iteration() {
        guard benchmarksEnabled else { return }
        let frames = 100
        for entityCount in entityCounts {
            compareBackends(
                scenarioLabel: "scenario1 iteration N=\(entityCount) frames=\(frames)"
            ) { backend in
                self.iterationRun(backend: backend, entityCount: entityCount, frames: frames)
            }
        }
    }

    private func iterationRun(backend: Backend, entityCount: Int, frames: Int) -> Double {
        let world = backend.makeWorld()
        world.addSystem(.update) { (query: Query3<Position, Velocity, Health>) in
            query.update { position, velocity, health in
                position.x += velocity.dx
                position.y += velocity.dy
                health.value &+= 1
            }
        }

        let commands = world.worldStorage.commands
        for _ in 0..<entityCount {
            commands.spawn()
                .addComponent(Position(x: 0, y: 0))
                .addComponent(Velocity(dx: 1, dy: 1))
                .addComponent(Health(value: 0))
        }

        // 準備フレーム: system は実行されず、spawn の flush のみ行われます(計測区間外)。
        world.update(currentTime: 0)

        // 計測対象: 100 フレームの update ループ。
        return measureMilliseconds {
            for frame in 1...frames {
                world.update(currentTime: TimeInterval(frame))
            }
        }
    }

    // MARK: シナリオ2: spawn/despawn (要件 5-1, 5-4)

    /// 登録 Query 数 k = 1, 10, 50 の World で N entities を spawn → 全 despawn する
    /// コストを計測します(要件 5-1「Query 数非比例」を k の変化で観測)。
    ///
    /// - マーカー Query は spawn する entity(`Payload` のみ)とマッチしません。
    ///   legacy では spawn/despawn が全 chunk へ broadcast されるため、マッチしない
    ///   Query の数に比例する分のコストがそのまま観測できます。
    /// - 計測対象: N spawn の enqueue + flush フレーム 1 回、全 despawn の
    ///   enqueue + flush フレーム 1 回(それぞれ 1 フレームずつ)。
    @Test func scenario2SpawnDespawn() {
        guard benchmarksEnabled else { return }
        for entityCount in entityCounts {
            for queryCount in [1, 10, 50] {
                compareBackends(
                    scenarioLabel: "scenario2 spawnDespawn N=\(entityCount) k=\(queryCount)"
                ) { backend in
                    self.spawnDespawnRun(
                        backend: backend,
                        entityCount: entityCount,
                        queryCount: queryCount
                    )
                }
            }
        }
    }

    private func spawnDespawnRun(backend: Backend, entityCount: Int, queryCount: Int) -> Double {
        precondition(
            queryCount <= markerQueryRegistrations.count,
            "queryCount exceeds the number of marker components."
        )
        let world = backend.makeWorld()
        for register in markerQueryRegistrations.prefix(queryCount) {
            register(world)
        }
        let commands = world.worldStorage.commands

        // 準備フレーム(計測区間外)。
        world.update(currentTime: 0)

        return measureMilliseconds {
            var entities = [Entity]()
            entities.reserveCapacity(entityCount)
            for _ in 0..<entityCount {
                let entity = commands.spawn()
                    .addComponent(Payload(value: 0))
                    .id()
                entities.append(entity)
            }
            // spawn の flush フレーム。
            world.update(currentTime: 1)

            for entity in entities {
                commands.despawn(entity: entity)
            }
            // despawn の flush フレーム。
            world.update(currentTime: 2)
        }
    }

    // MARK: シナリオ3: 空コマンド (要件 3-4 の退行検出)

    /// N の生存 entity へ `commands.entity(e)` のみ(component 変更なし)を発行し、
    /// enqueue + flush フレーム 1 回を計測します。
    ///
    /// - archetype ON では空 diff は no-op マーカーとして早期に捨てられるはずで
    ///   (要件 3-4)、その退行を検出します。
    /// - legacy 側で updated-entity queue の適用先となる chunk が存在するよう、
    ///   `Query<Payload>` を 1 つ登録した状態で比較します(新旧同条件)。
    @Test func scenario3EmptyCommands() {
        guard benchmarksEnabled else { return }
        for entityCount in entityCounts {
            compareBackends(
                scenarioLabel: "scenario3 emptyCommands N=\(entityCount)"
            ) { backend in
                self.emptyCommandsRun(backend: backend, entityCount: entityCount)
            }
        }
    }

    private func emptyCommandsRun(backend: Backend, entityCount: Int) -> Double {
        let world = backend.makeWorld()
        world.addSystem(.update) { (_: Query<Payload>) in }
        let commands = world.worldStorage.commands

        var entities = [Entity]()
        entities.reserveCapacity(entityCount)
        for _ in 0..<entityCount {
            let entity = commands.spawn()
                .addComponent(Payload(value: 0))
                .id()
            entities.append(entity)
        }

        // 準備フレーム: spawn の flush(計測区間外)。
        world.update(currentTime: 0)

        return measureMilliseconds {
            for entity in entities {
                _ = commands.entity(entity)
            }
            // 空コマンドの flush フレーム。
            world.update(currentTime: 1)
        }
    }
}
