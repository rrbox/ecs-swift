//
//  SearchedEntityDiffTests.swift
//
//
//  Created by rrbox on 2026/07/08.
//

@testable import ECS
import Testing

/// searched entity 経路の差分トランザクション(`SearchedEntityDiffQueue` /
/// `ComponentDiff`)のテストです(タスク 6.1)。
///
/// 同一型への重複差分の「後勝ち」正規化(要件 3-3)と、空 diff の no-op マーカー
/// (要件 3-4)を検証します。
struct SearchedEntityDiffTests {

    struct ComponentA: Component, Equatable {
        var value: Int
    }

    struct ComponentB: Component, Equatable {
        var text: String
    }

    private let entity = Entity(slot: 0, generation: 0)

    // MARK: - helpers

    /// `.add` 差分から保持値を取り出します。`.remove` や型不一致の場合は nil です。
    private func addValue<T: Component>(_ diff: ComponentDiff, as type: T.Type) -> T? {
        guard case .add(let insertable) = diff else { return nil }
        return (insertable as? ComponentRef<T>)?.value
    }

    /// `.remove` 差分から型キーを取り出します。`.add` の場合は nil です。
    private func removeKey(_ diff: ComponentDiff) -> ObjectIdentifier? {
        guard case .remove(let key) = diff else { return nil }
        return key
    }

    // MARK: - 後勝ち正規化 (要件 3-3)

    /// 同一型への add → remove は remove(後勝ち)に正規化されます。
    @Test func addThenRemoveSameTypeNormalizesToRemove() {
        let queue = SearchedEntityDiffQueue(entity: self.entity)
        queue.diffs.append(.add(ComponentRef(value: ComponentA(value: 1))))
        queue.diffs.append(.remove(ObjectIdentifier(ComponentA.self)))

        let normalized = queue.normalizedDiffs()

        #expect(normalized.count == 1)
        #expect(self.removeKey(normalized[0]) == ObjectIdentifier(ComponentA.self))
    }

    /// 同一型への remove → add は add(後勝ち)に正規化され、値が保持されます。
    @Test func removeThenAddSameTypeNormalizesToAdd() {
        let queue = SearchedEntityDiffQueue(entity: self.entity)
        queue.diffs.append(.remove(ObjectIdentifier(ComponentA.self)))
        queue.diffs.append(.add(ComponentRef(value: ComponentA(value: 42))))

        let normalized = queue.normalizedDiffs()

        #expect(normalized.count == 1)
        #expect(self.addValue(normalized[0], as: ComponentA.self) == ComponentA(value: 42))
    }

    /// 同一型への add → add は最後の値のみが残ります。
    @Test func duplicateAddsKeepOnlyLastValue() {
        let queue = SearchedEntityDiffQueue(entity: self.entity)
        queue.diffs.append(.add(ComponentRef(value: ComponentA(value: 1))))
        queue.diffs.append(.add(ComponentRef(value: ComponentA(value: 2))))

        let normalized = queue.normalizedDiffs()

        #expect(normalized.count == 1)
        #expect(self.addValue(normalized[0], as: ComponentA.self) == ComponentA(value: 2))
    }

    // MARK: - 空 diff の no-op マーカー (要件 3-4)

    /// diff が積まれていない queue は `diffs.isEmpty` が no-op マーカーとして機能し、
    /// 正規化結果も空になります。
    @Test func emptyDiffQueueIsNoOpMarker() {
        let queue = SearchedEntityDiffQueue(entity: self.entity)

        #expect(queue.diffs.isEmpty)
        #expect(queue.normalizedDiffs().isEmpty)
    }

    // MARK: - 異なる型の差分の保存

    /// 異なる型の差分は正規化で失われず、種別と値がすべて保持されます。
    @Test func distinctTypesArePreservedByNormalization() {
        let queue = SearchedEntityDiffQueue(entity: self.entity)
        queue.diffs.append(.add(ComponentRef(value: ComponentA(value: 1))))
        queue.diffs.append(.remove(ObjectIdentifier(ComponentB.self)))

        let normalized = queue.normalizedDiffs()

        #expect(normalized.count == 2)
        #expect(self.addValue(normalized[0], as: ComponentA.self) == ComponentA(value: 1))
        #expect(self.removeKey(normalized[1]) == ObjectIdentifier(ComponentB.self))
    }

    // MARK: - EntityCommands フックと Commands.entity(_) の分岐 (要件 3-2)

    /// テスト用の bundle です。`@Bundle` マクロと同じ `BundleProtocol` の
    /// 公開面(record への addComponent)を手書きで実装しています。
    struct TestBundle: BundleProtocol {
        let a: ComponentA
        let b: ComponentB

        func addComponent(forEntity record: EntityRecordRef) {
            record.addComponent(self.a)
            record.addComponent(self.b)
        }
    }

    /// `Commands.entityTransactions` から diff queue を取り出します。
    private func diffQueues(in commands: Commands) -> [SearchedEntityDiffQueue] {
        commands.entityTransactions.compactMap { $0 as? SearchedEntityDiffQueue }
    }

    /// ON: `commands.entity(e).addComponent(...)` が add 差分として蓄積されます
    /// (公開 API は現行と同一、要件 3-2)。
    @Test func entityCommandsOnArchetypeWorldEnqueuesAddDiff() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        commands.entity(self.entity)
            .addComponent(ComponentA(value: 3))

        let queue = try #require(self.diffQueues(in: commands).first)
        #expect(queue.entity == self.entity)
        #expect(queue.diffs.count == 1)
        #expect(self.addValue(queue.diffs[0], as: ComponentA.self) == ComponentA(value: 3))
    }

    /// ON: `removeComponent(ofType:)` が remove 差分として蓄積されます。
    @Test func entityCommandsOnArchetypeWorldEnqueuesRemoveDiff() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        commands.entity(self.entity)
            .removeComponent(ofType: ComponentA.self)

        let queue = try #require(self.diffQueues(in: commands).first)
        #expect(queue.diffs.count == 1)
        #expect(self.removeKey(queue.diffs[0]) == ObjectIdentifier(ComponentA.self))
    }

    /// ON: `addBundle` が bundle 内の各コンポーネントの add 差分へ展開されます
    /// (`@Bundle` 互換の維持)。
    @Test func entityCommandsOnArchetypeWorldExpandsBundleIntoAddDiffs() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        commands.entity(self.entity)
            .addBundle(TestBundle(a: ComponentA(value: 5), b: ComponentB(text: "b")))

        let queue = try #require(self.diffQueues(in: commands).first)
        #expect(queue.diffs.count == 2)

        // record(Dictionary)経由の展開のため差分の順序は不定です。型キー集合と値で検証します。
        let addedValuesA = queue.diffs.compactMap { self.addValue($0, as: ComponentA.self) }
        let addedValuesB = queue.diffs.compactMap { self.addValue($0, as: ComponentB.self) }
        #expect(addedValuesA == [ComponentA(value: 5)])
        #expect(addedValuesB == [ComponentB(text: "b")])
    }

    /// ON: メソッドチェーン(公開 API 不変)で複数の差分が同一 queue に蓄積されます。
    @Test func entityCommandsOnArchetypeWorldChainsIntoSingleQueue() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands

        commands.entity(self.entity)
            .addComponent(ComponentA(value: 1))
            .removeComponent(ofType: ComponentB.self)

        let queues = self.diffQueues(in: commands)
        #expect(queues.count == 1)
        #expect(queues.first?.diffs.count == 2)
    }

    /// OFF: `commands.entity(e)` は従来どおり `SearchedEntityCommandQueue` に
    /// `EntityCommand` を積みます(diff queue は生成されません、要件 4-1)。
    @Test func entityCommandsOnLegacyWorldKeepsCommandQueuePath() throws {
        let world = World()
        let commands = world.worldStorage.commands

        commands.entity(self.entity)
            .addComponent(ComponentA(value: 1))
            .removeComponent(ofType: ComponentA.self)

        #expect(self.diffQueues(in: commands).isEmpty)

        let queue = try #require(
            commands.entityTransactions
                .compactMap { $0 as? SearchedEntityCommandQueue }
                .first
        )
        #expect(queue.entity == self.entity)
        #expect(queue.queue.count == 2)
        #expect(queue.queue[0] is AddComponent<ComponentA>)
        #expect(queue.queue[1] is RemoveComponent<ComponentA>)
    }

    // MARK: - ストレージ (diffQueues)

    /// `ArchetypeStorageRef` は diff queue の蓄積先(`diffQueues`)を持ちます
    /// (旧 updatedEntityQueue 相当、design.md ArchetypeStorageRef)。
    @Test func archetypeStorageRefHasDiffQueuesStorage() {
        let storage = ArchetypeStorageRef()

        #expect(storage.diffQueues.isEmpty)

        let queue = SearchedEntityDiffQueue(entity: self.entity)
        storage.diffQueues.append(queue)

        #expect(storage.diffQueues.count == 1)
        #expect(storage.diffQueues.first === queue)
    }

    // MARK: - flush 適用: archetype 移動 (タスク 6.3, 要件 1-3, 3-4, 5-1)

    struct ComponentC: Component, Equatable {
        var flag: Bool
    }

    private func column<T: Component>(
        of type: T.Type,
        in archetype: Archetype,
        storage: ArchetypeStorageRef
    ) throws -> Column<T> {
        let id = storage.typeID(for: ObjectIdentifier(T.self))
        return try #require(archetype.column(of: id) as? Column<T>)
    }

    /// ON: `addComponent` により entity が次フレームで Query の対象に入ります(要件 1-3)。
    @Test func addComponentMovesEntityIntoQueryScopeOnNextFrame() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands
        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()

        var observedPerFrame = [[Int]]()
        world.addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
            var values = [Int]()
            query.update { a, _ in values.append(a.value) }
            observedPerFrame.append(values)
        }

        world.update(currentTime: 0)
        world.update(currentTime: 1)

        commands.entity(entity).addComponent(ComponentB(text: "b"))
        world.update(currentTime: 2)

        // B 追加前のフレームでは対象外、追加が適用された後のフレームで対象に入ります。
        #expect(observedPerFrame == [[], [1]])

        // 移動後の所在と両カラムの値が正しいことを確認します。
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let location = try #require(storage.location(of: entity))
        let columnA = try self.column(of: ComponentA.self, in: location.archetype, storage: storage)
        let columnB = try self.column(of: ComponentB.self, in: location.archetype, storage: storage)
        #expect(columnA.data[location.row] == ComponentA(value: 1))
        #expect(columnB.data[location.row] == ComponentB(text: "b"))

        // diff queue は適用後にクリアされます。
        #expect(storage.diffQueues.isEmpty)
    }

    /// ON: `removeComponent` により entity が Query の対象から外れます(要件 1-3)。
    /// 削除されなかったコンポーネントの値は移動後も保持されます。
    @Test func removeComponentMovesEntityOutOfQueryScope() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let commands = world.worldStorage.commands
        let entity = commands.spawn()
            .addComponent(ComponentA(value: 7))
            .addComponent(ComponentB(text: "x"))
            .id()

        var observedPerFrame = [[Int]]()
        world.addSystem(.update) { (query: Query2<ComponentA, ComponentB>) in
            var values = [Int]()
            query.update { a, _ in values.append(a.value) }
            observedPerFrame.append(values)
        }

        world.update(currentTime: 0)
        world.update(currentTime: 1)

        commands.entity(entity).removeComponent(ofType: ComponentB.self)
        world.update(currentTime: 2)

        #expect(observedPerFrame == [[7], []])

        // 移動先は {A} のみの Archetype で、A の値は保持されます。
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let location = try #require(storage.location(of: entity))
        #expect(location.archetype.key.ids.count == 1)
        let columnA = try self.column(of: ComponentA.self, in: location.archetype, storage: storage)
        #expect(columnA.data[location.row] == ComponentA(value: 7))
    }

    /// ON: 既に持っている型への `addComponent` は Archetype 移動を起こさず、
    /// その行の値を上書きします(target key が同一になるエッジケース)。
    @Test func addComponentOfExistingTypeOverwritesValueInPlace() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands
        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.update(currentTime: 0)

        let before = try #require(storage.location(of: entity))
        let archetypeCountBefore = storage.archetypes.count

        commands.entity(entity).addComponent(ComponentA(value: 5))
        world.update(currentTime: 1)

        let after = try #require(storage.location(of: entity))
        #expect(after.archetype === before.archetype)
        #expect(after.row == before.row)
        #expect(storage.archetypes.count == archetypeCountBefore)

        let columnA = try self.column(of: ComponentA.self, in: after.archetype, storage: storage)
        #expect(columnA.data[after.row] == ComponentA(value: 5))
    }

    /// ON: 持っていない型の `removeComponent` は no-op で、Archetype 移動を起こしません。
    @Test func removeComponentOfAbsentTypeIsNoOp() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands
        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.update(currentTime: 0)

        let before = try #require(storage.location(of: entity))
        let archetypeCountBefore = storage.archetypes.count

        commands.entity(entity).removeComponent(ofType: ComponentB.self)
        world.update(currentTime: 1)

        let after = try #require(storage.location(of: entity))
        #expect(after.archetype === before.archetype)
        #expect(after.row == before.row)
        #expect(storage.archetypes.count == archetypeCountBefore)
    }

    /// ON: 同一型への add → remove(正規化で remove、対象型は元々持っていない)は
    /// 構造変更なしで完了し、Archetype 移動を起こしません。
    @Test func addThenRemoveSameAbsentTypeCausesNoArchetypeChange() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands
        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.update(currentTime: 0)

        let before = try #require(storage.location(of: entity))
        let archetypeCountBefore = storage.archetypes.count

        commands.entity(entity)
            .addComponent(ComponentB(text: "temp"))
            .removeComponent(ofType: ComponentB.self)
        world.update(currentTime: 1)

        let after = try #require(storage.location(of: entity))
        #expect(after.archetype === before.archetype)
        #expect(after.row == before.row)
        #expect(storage.archetypes.count == archetypeCountBefore)
    }

    /// ON: `commands.entity(e)` のみ(空 diff)は Archetype 移動も新規 Archetype 生成も
    /// 起こしません(要件 3-4)。
    @Test func emptyEntityCommandsCauseNoArchetypeChange() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands
        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.update(currentTime: 0)

        let before = try #require(storage.location(of: entity))
        let archetypeCountBefore = storage.archetypes.count

        _ = commands.entity(entity)
        world.update(currentTime: 1)

        // 空 diff は diffQueues にすら積まれず、所在・Archetype 数ともに不変です。
        #expect(storage.diffQueues.isEmpty)
        let after = try #require(storage.location(of: entity))
        #expect(after.archetype === before.archetype)
        #expect(after.row == before.row)
        #expect(storage.archetypes.count == archetypeCountBefore)
    }

    /// ON: 同一フレームで diff と despawn が積まれた場合、despawn 済み entity への
    /// diff 適用は silent skip され、クラッシュしません。
    @Test func diffForEntityDespawnedInSameFrameIsSilentlySkipped() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands
        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        world.update(currentTime: 0)

        commands.entity(entity).addComponent(ComponentB(text: "b"))
        commands.despawn(entity: entity)
        world.update(currentTime: 1)

        #expect(storage.location(of: entity) == nil)
        #expect(storage.diffQueues.isEmpty)
    }

    /// ON: 同一 Archetype の複数 entity のうち行 0 の entity を移動させたとき、
    /// swap-remove で行 0 を埋めた entity(filler)の所在・値が正しく補正されます
    /// (`entityIndex.update(forEntity:)` による補正)。
    @Test func swapRemoveFillerEntityLocationIsCorrectedAfterMove() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands

        let first = commands.spawn()
            .addComponent(ComponentA(value: 10))
            .id()
        let second = commands.spawn()
            .addComponent(ComponentA(value: 20))
            .id()

        var queryValueForSecond: Int?
        world.addSystem(.update) { (query: Query<ComponentA>) in
            queryValueForSecond = query.components(forEntity: second)?.value
        }

        world.update(currentTime: 0)

        // 2 entity が同一 Archetype の行 0, 1 に入っていることを前提として確認します。
        let sourceBefore = try #require(storage.location(of: first))
        #expect(sourceBefore.row == 0)
        #expect(try #require(storage.location(of: second)).row == 1)

        // 行 0 の entity を移動させ、行 1 の entity が filler として行 0 に落ちます。
        commands.entity(first).addComponent(ComponentB(text: "moved"))
        world.update(currentTime: 1)

        // filler(second)の所在が行 0 に補正され、値の解決も正しいままです。
        let fillerLocation = try #require(storage.location(of: second))
        #expect(fillerLocation.archetype === sourceBefore.archetype)
        #expect(fillerLocation.row == 0)
        let columnA = try self.column(of: ComponentA.self, in: fillerLocation.archetype, storage: storage)
        #expect(columnA.data[fillerLocation.row] == ComponentA(value: 20))
        #expect(queryValueForSecond == 20)

        // 移動した entity(first)の所在と値も正しいことを確認します。
        let movedLocation = try #require(storage.location(of: first))
        #expect(movedLocation.archetype !== sourceBefore.archetype)
        let movedColumnA = try self.column(of: ComponentA.self, in: movedLocation.archetype, storage: storage)
        let movedColumnB = try self.column(of: ComponentB.self, in: movedLocation.archetype, storage: storage)
        #expect(movedColumnA.data[movedLocation.row] == ComponentA(value: 10))
        #expect(movedColumnB.data[movedLocation.row] == ComponentB(text: "moved"))
    }

    /// ON: 単一コンポーネント追加の移動で archetype graph の辺(addEdges / removeEdges)が
    /// キャッシュされ、2 回目以降の同じ移動で再利用されます(要件 5-1)。
    @Test func singleComponentMoveCachesArchetypeEdges() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands

        let first = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .id()
        let second = commands.spawn()
            .addComponent(ComponentA(value: 2))
            .id()
        world.update(currentTime: 0)

        let source = try #require(storage.location(of: first)).archetype

        commands.entity(first).addComponent(ComponentB(text: "b"))
        world.update(currentTime: 1)

        // 辺が双方向にキャッシュされます。
        let idB = storage.typeID(for: ObjectIdentifier(ComponentB.self))
        let target = try #require(storage.location(of: first)).archetype
        #expect(source.addEdges[idB] === target)
        #expect(target.removeEdges[idB] === source)

        // 2 回目の同じ移動では新規 Archetype が生成されません(辺の再利用)。
        let archetypeCountBefore = storage.archetypes.count
        commands.entity(second).addComponent(ComponentB(text: "b2"))
        world.update(currentTime: 2)

        #expect(storage.archetypes.count == archetypeCountBefore)
        #expect(try #require(storage.location(of: second)).archetype === target)
    }

    /// ON: 複数差分(remove + add)の複合移動でも所在と値が正しく反映されます。
    @Test func combinedRemoveAndAddDiffsMoveEntityToCorrectArchetype() throws {
        let world = World(experimentalOptions: [.archetypeStorage])
        let storage = try #require(world.worldStorage.archetypeStorageRef)
        let commands = world.worldStorage.commands
        let entity = commands.spawn()
            .addComponent(ComponentA(value: 1))
            .addComponent(ComponentB(text: "keep"))
            .id()
        world.update(currentTime: 0)

        commands.entity(entity)
            .removeComponent(ofType: ComponentA.self)
            .addComponent(ComponentC(flag: true))
        world.update(currentTime: 1)

        let location = try #require(storage.location(of: entity))
        #expect(location.archetype.key.ids.count == 2)
        let columnB = try self.column(of: ComponentB.self, in: location.archetype, storage: storage)
        let columnC = try self.column(of: ComponentC.self, in: location.archetype, storage: storage)
        #expect(columnB.data[location.row] == ComponentB(text: "keep"))
        #expect(columnC.data[location.row] == ComponentC(flag: true))

        // A は移動対象外(破棄)なので、移動先に A のカラムはありません。
        let idA = storage.typeID(for: ObjectIdentifier(ComponentA.self))
        #expect(location.archetype.column(of: idA) == nil)
    }
}
