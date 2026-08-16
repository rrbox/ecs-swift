//
//  Query.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

/// Archetype バックエンドでの 1 マッチ(マッチした Archetype と、解決済みのアクセス経路)です。
///
/// `archetype` は `ArchetypeStorageRef` と同寿命の Archetype を参照するため
/// `unowned` で保持します(`EntityLocation` と同じ設計方針)。
struct ArchetypeMatch<C: QueryTarget> {
    unowned let archetype: Archetype
    let access: ColumnAccess<C>
}

final public class Query<C: QueryTarget>: Chunk, SystemParameter {
    var components = SparseSet<Ref<C>>(sparse: [], dense: [], data: [])

    // MARK: - Archetype バックエンド (archetype storage ON)

    /// マッチ済みの Archetype 一覧です。OFF の World では常に空です。
    var archetypeMatches = [ArchetypeMatch<C>]()

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
    /// 重複型 assertion(要件 2-8)の検査対象で、1 型の Query では重複は自明に
    /// 発生しませんが、QueryN(マクロ生成)と同じ形を共有します。
    static var requiredComponentTypeKeys: [ObjectIdentifier] {
        ColumnAccess<C>.isEntity ? [] : [ObjectIdentifier(C.self)]
    }

    public override init() {}

    public func insert(entityRecord: EntityRecordRef) {
        guard let componentRef = entityRecord.ref(C.self) else { return }
        self.components.insert(componentRef, withEntity: entityRecord.entity)
    }

    public func remove(entity: Entity) {
        guard self.components.contains(entity) else { return }
        self.components.pop(entity: entity)
    }

    override func spawn(entityRecord: EntityRecordRef) {
        self.insert(entityRecord: entityRecord)
    }

    override func despawn(entity: Entity) {
        self.remove(entity: entity)
    }

    override func applyCurrentState(_ entityRecord: EntityRecordRef) {
        guard let componentRef = entityRecord.ref(C.self) else {
            self.despawn(entity: entityRecord.entity)
            return
        }
        guard !components.contains(entityRecord.entity) else { return }
        self.components.insert(
            componentRef,
            withEntity: entityRecord.entity
        )
    }

    /// Query で指定した Component を持つ entity を world から取得し, イテレーションします.
    ///
    /// バックエンドは register 時に確定しているため, イテレーション経路にオプション分岐は
    /// ありません: OFF では `archetypeMatches` が, ON では `components` が常に空です.
    public func update(_ f: (inout C) -> ()) {
        // chunk バックエンド (OFF)
        for ref in self.components.data {
            f(&ref.value)
        }
        // Archetype バックエンド (ON)
        for match in self.archetypeMatches {
            switch match.access {
            case .column(let column):
                // `&data[i]` への直接アクセスのため, 要素ごとの動的ディスパッチはありません(要件 5-2)。
                for i in column.data.indices {
                    f(&column.data[i])
                }
            case .entity:
                // Entity ターゲットへの書き込みは破棄されます(要件 2-6)。
                for row in match.archetype.entities.indices {
                    var value = match.access.value(at: row, in: match.archetype)
                    f(&value)
                }
            }
        }
    }

    public func update(_ entity: Entity, _ f: (inout C) -> ()) {
        if let storage = self.archetypeStorage {
            guard let match = self.archetypeRow(of: entity, in: storage) else { return }
            switch match.access {
            case .column(let column):
                f(&column.data[match.row])
            case .entity:
                // Entity ターゲットへの書き込みは破棄されます(要件 2-6)。
                var value = match.access.value(at: match.row, in: match.archetype)
                f(&value)
            }
            return
        }
        guard let ref = self.components.value(forEntity: entity) else { return }
        f(&ref.value)
    }

    public func components(forEntity entity: Entity) -> C? {
        if let storage = self.archetypeStorage {
            guard let match = self.archetypeRow(of: entity, in: storage) else { return nil }
            return match.access.value(at: match.row, in: match.archetype)
        }
        return self.components.value(forEntity: entity)?.value
    }

    public static func register(to worldStorage: WorldStorageRef) {
        guard worldStorage.chunkStorageRef.chunk(ofType: Self.self) == nil else {
            return
        }

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
    /// 1 型の Query では `ColumnAccess.resolve` がそのまま判定を兼ねます
    /// (`Entity` ターゲットは要求が空のため常にマッチします)。
    func matchArchetype(_ archetype: Archetype, storage: ArchetypeStorageRef) {
        guard let access = ColumnAccess<C>.resolve(in: archetype, storage: storage) else { return }
        self.archetypeMatches.append(ArchetypeMatch(archetype: archetype, access: access))
    }

    /// entity の所在をマッチ済み Archetype から引き, アクセス経路と行番号を返します。
    ///
    /// entity が despawn 済み・世代不一致・この Query の対象型を持たない場合は nil です(要件 2-7)。
    private func archetypeRow(
        of entity: Entity,
        in storage: ArchetypeStorageRef
    ) -> (archetype: Archetype, access: ColumnAccess<C>, row: Int)? {
        guard let location = storage.location(of: entity),
              let match = self.archetypeMatches.first(where: { $0.archetype === location.archetype })
        else { return nil }
        return (match.archetype, match.access, location.row)
    }

}

extension Query: ArchetypeObserver {
    /// 新しい Archetype の生成通知を受け, マッチ判定を行います。
    ///
    /// - Important: `findOrCreate` は `applySpawnStaging` の drain 中にも呼ばれるため,
    ///   この実装では `spawnStagingQueue` に触れてはいけません(silent drop の原因になります)。
    func archetypeCreated(_ archetype: Archetype, storage: ArchetypeStorageRef) {
        self.matchArchetype(archetype, storage: storage)
    }
}
