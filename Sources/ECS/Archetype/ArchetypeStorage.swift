//
//  ArchetypeStorage.swift
//
//
//  Created by rrbox on 2026/07/07.
//

/// entity の所在(所属 Archetype と行番号)を表します。
///
/// `archetype` は `ArchetypeStorageRef` と同寿命の Archetype を参照するため
/// `unowned` で保持します(空 Archetype の回収は行わない設計方針に依存します)。
struct EntityLocation {
    /// entity が所属する Archetype です。
    unowned let archetype: Archetype

    /// Archetype 内の行番号です。
    var row: Int
}

/// 新しい Archetype の生成を購読するオブザーバです。
///
/// Query が適合し、生成された Archetype と自身のマッチングを行う想定です。
/// `ArchetypeStorageRef` はオブザーバを強参照で保持しますが、Query は World と
/// 同寿命であるため循環の問題はありません(設計方針)。
protocol ArchetypeObserver: AnyObject {
    /// 新しい Archetype が生成されたときに呼ばれます。
    /// - Parameters:
    ///   - archetype: 生成された Archetype。
    ///   - storage: 生成元のストレージ。
    func archetypeCreated(_ archetype: Archetype, storage: ArchetypeStorageRef)
}

/// Archetype の検索・生成、entity 所在管理、新規 Archetype 通知を担うストレージです。
///
/// World ごとに 1 つ保持され、`ComponentTypeID` の採番レジストリもインスタンス単位で
/// 持ちます(World 間で採番が干渉しないようにするため)。
final class ArchetypeStorageRef {
    /// 生成順の Archetype 一覧です。
    var archetypes = [Archetype]()

    /// 型集合キー → Archetype の索引です。
    var byKey = [ArchetypeKey: Archetype]()

    /// entity → 所在(Archetype と行番号)の対応表です。
    var entityIndex = SparseSet<EntityLocation>(sparse: [], dense: [], data: [])

    /// 新規 Archetype 生成の通知先です。
    var observers = [ArchetypeObserver]()

    /// spawn 待ちの entity record キューです(旧 prespawnedEntityQueue 相当)。
    var spawnStagingQueue = [EntityRecordRef]()

    /// `ObjectIdentifier` → `ComponentTypeID` の採番レジストリです。
    private let typeRegistry = ComponentTypeRegistry()

    /// 型キーに対応する `ComponentTypeID` を返します。未登録の場合は新しい ID を採番します。
    /// - Parameter key: コンポーネント型の `ObjectIdentifier`。
    /// - Returns: 型キーに対応する `ComponentTypeID`。
    func typeID(for key: ObjectIdentifier) -> ComponentTypeID {
        self.typeRegistry.typeID(for: key)
    }

    /// キーに対応する Archetype を返します。存在しない場合は生成し、オブザーバへ通知します。
    ///
    /// 既存の Archetype が見つかった場合、`prototypes` は使用されず破棄されます。
    /// - Parameters:
    ///   - key: 型集合キー。
    ///   - prototypes: `key.ids` と並行な空カラム配列。生成時のみ使用されます。
    /// - Returns: キーに対応する Archetype。
    func findOrCreate(key: ArchetypeKey, prototypes: [AnyColumn]) -> Archetype {
        if let existing = self.byKey[key] {
            return existing
        }
        assert(
            prototypes.allSatisfy { $0.count == 0 },
            "Archetype prototypes must be empty columns."
        )
        let archetype = Archetype(key: key, columns: prototypes)
        self.archetypes.append(archetype)
        self.byKey[key] = archetype
        for observer in self.observers {
            observer.archetypeCreated(archetype, storage: self)
        }
        return archetype
    }

    /// entity の所在を返します。
    ///
    /// 世代チェックを含みます(要件 1-4): despawn 済み、またはスロットが別世代で
    /// (再)利用されている entity には nil を返します。世代の照合は
    /// `SparseSet.value(forEntity:)` が dense に保存した entity と slot + generation の
    /// 両方で比較することにより行われます。
    /// - Parameter entity: 所在を調べる entity。
    /// - Returns: entity の所在。未登録・世代不一致の場合は nil。
    func location(of entity: Entity) -> EntityLocation? {
        guard self.entityIndex.contains(entity) else { return nil }
        return self.entityIndex.value(forEntity: entity)
    }

    /// entity の所在を登録します。
    ///
    /// `SparseSet` の `allocate()` 規約に従い、generation == 0 の entity(新規スロット)は
    /// sparse 配列を伸ばしてから挿入します(現行実装の spawn 手順を踏襲、設計方針)。
    /// - Parameters:
    ///   - location: 登録する所在。
    ///   - entity: 対象の entity。
    func setLocation(_ location: EntityLocation, forEntity entity: Entity) {
        if entity.generation == 0 {
            self.entityIndex.allocate()
        }
        self.entityIndex.insert(location, withEntity: entity)
    }

    /// entity の所在を削除します(despawn 対応)。
    ///
    /// 未登録、または世代が一致しない entity への要求は無視します。
    /// - Parameter entity: 対象の entity。
    func removeLocation(of entity: Entity) {
        guard self.location(of: entity) != nil else { return }
        self.entityIndex.pop(entity: entity)
    }
}
