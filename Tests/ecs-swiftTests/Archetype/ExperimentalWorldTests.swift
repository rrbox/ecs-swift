//
//  ExperimentalWorldTests.swift
//
//
//  Created by rrbox on 2026/07/07.
//

@testable import ECS
import Testing

struct ExperimentalWorldTests {

    /// 既存の `World()` はオプションなし・archetype storage なしで初期化されることを確認します。
    @Test func defaultInitHasNoExperimentalOptions() {
        let world = World()
        #expect(world.worldStorage.experimentalOptions == [])
        #expect(world.worldStorage.archetypeStorageRef == nil)
    }

    /// `archetypeStorage` オプション指定時に `ArchetypeStorageRef` が生成されることを確認します。
    @Test func archetypeStorageOptionCreatesArchetypeStorageRef() {
        let world = World(experimentalOptions: [.archetypeStorage])
        #expect(world.worldStorage.experimentalOptions == [.archetypeStorage])
        #expect(world.worldStorage.archetypeStorageRef != nil)
    }

    /// ON 時も `setUpChunkBuffer` が実行され、chunk buffer がパラメータレジストリとして
    /// 維持されることを確認します(design.md 分岐点1)。
    @Test func archetypeStorageOptionKeepsChunkBufferSetUp() {
        let world = World(experimentalOptions: [.archetypeStorage])
        // setUpChunkBuffer() は ChunkEntityInterface を登録します。
        #expect(world.worldStorage.chunkStorageRef.storage.valueRef(ofType: ChunkEntityInterface.self) != nil)
    }

    // NOTE: `WorldStorageRef.experimentalOptions` と `archetypeStorageRef` は `let` で宣言されるため、
    // 初期化後の不変性はコンパイル時に保証されます(要件 4-4)。実行時テストは不要です。
}
