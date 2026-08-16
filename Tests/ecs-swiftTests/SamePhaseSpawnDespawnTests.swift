//
//  SamePhaseSpawnDespawnTests.swift
//  ECS_Swift
//
//  Created by rrbox on 2026/08/16.
//

import Testing
@testable import ECS

private final class EntityBox {
    var handle: Entity?
    var contentsPerFrame: [Double: [String]] = [:]
}

/// spawn した phase と despawn する phase の関係についてのテストです.
struct SamePhaseSpawnDespawnTests {
    /// phase をまたぐ spawn → despawn は正常な操作です.
    ///
    /// preUpdate で spawn した entity は同じフレームの update では有効で,
    /// postUpdate の despawn によって次のフレームでは削除されている必要があります.
    @Test func spawnInPreUpdateAndDespawnInPostUpdateKeepsWorking() {
        let spawnFrame = 1.0
        let box = EntityBox()
        let world = World()
            .addSystem(.preUpdate) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == spawnFrame else { return }
                box.handle = commands.spawn()
                    .addComponent(TestComponent(content: "cross phase"))
                    .id()
            }
            .addSystem(.update) { (query: Query<TestComponent>, time: Resource<CurrentTime>) in
                var contents: [String] = []
                query.update { (component: inout TestComponent) in
                    contents.append(component.content)
                }
                box.contentsPerFrame[time.resource.value] = contents
            }
            .addSystem(.postUpdate) { (commands: Commands, time: Resource<CurrentTime>) in
                guard time.resource.value == spawnFrame, let handle = box.handle else { return }
                commands.despawn(entity: handle)
            }

        for frame in stride(from: 0.0, through: 2.0, by: 1.0) {
            world.update(currentTime: frame)
        }

        #expect(box.contentsPerFrame[1.0] == ["cross phase"])
        #expect(box.contentsPerFrame[2.0] == [])
    }

#if compiler(>=6.2) && DEBUG && (os(macOS) || os(Linux) || os(Windows))
    /// 同一 phase 内の spawn → despawn は debug ビルドで assertion により検出されます.
    @Test func spawnAndDespawnInSamePhaseTraps() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let world = World()
                .addSystem(.startUp) { (commands: Commands) in
                    let handle = commands.spawn()
                        .addComponent(TestComponent(content: "same phase"))
                        .id()
                    commands.despawn(entity: handle)
                }
            world.update(currentTime: 0)
        }

        let standardError = String(decoding: result?.standardErrorContent ?? [], as: UTF8.self)
        #expect(standardError.contains("Despawning an entity in the same phase it was spawned"))
    }

    /// archetype storage ON でも同一 phase 内の spawn → despawn は同じ assertion で
    /// 検出されます(`ArchetypeStorageRef.despawn` の検出。legacy 側と対称)。
    ///
    /// exit test の子プロセスは値のキャプチャに制約があるため、`WorldBackend` による
    /// パラメタライズではなく ON 専用のテストとして併設しています。
    @Test func spawnAndDespawnInSamePhaseTrapsOnArchetypeStorage() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let world = World(experimentalOptions: [.archetypeStorage])
                .addSystem(.startUp) { (commands: Commands) in
                    let handle = commands.spawn()
                        .addComponent(TestComponent(content: "same phase"))
                        .id()
                    commands.despawn(entity: handle)
                }
            world.setUpWorld()
            world.update(currentTime: 0)
        }

        let standardError = String(decoding: result?.standardErrorContent ?? [], as: UTF8.self)
        #expect(standardError.contains("Despawning an entity in the same phase it was spawned"))
    }
#endif
}
