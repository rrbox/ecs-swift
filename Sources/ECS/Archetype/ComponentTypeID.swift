//
//  ComponentTypeID.swift
//
//
//  Created by rrbox on 2026/07/06.
//

/// コンポーネント型を識別する連番 ID です。
///
/// `ObjectIdentifier` の代わりに軽量な `Int` で型を識別するためのラッパーで、
/// Archetype のキー(ソート済み ID 配列)の構成要素として使用します。
/// ID は `ComponentTypeRegistry` が採番順(登録順)に払い出すため、
/// `Comparable` の順序は採番順と一致します。
struct ComponentTypeID: Hashable, Comparable {
    let value: Int

    static func < (lhs: ComponentTypeID, rhs: ComponentTypeID) -> Bool {
        lhs.value < rhs.value
    }
}

/// `ObjectIdentifier` から `ComponentTypeID` を払い出すレジストリです。
///
/// 同じ型キーには常に同じ ID を返し、未登録の型キーには 0 から始まる連番を採番します。
/// World(将来的には `ArchetypeStorageRef`)ごとにインスタンスを保持する想定で、
/// グローバルな static 状態にはしません(並列テストで World 間の採番が干渉しないようにするため)。
final class ComponentTypeRegistry {
    private var ids = [ObjectIdentifier: ComponentTypeID]()

    /// 型キーに対応する `ComponentTypeID` を返します。未登録の場合は新しい ID を採番します。
    /// - Parameter key: コンポーネント型の `ObjectIdentifier`。
    /// - Returns: 型キーに対応する `ComponentTypeID`。
    func typeID(for key: ObjectIdentifier) -> ComponentTypeID {
        if let id = self.ids[key] {
            return id
        }
        let id = ComponentTypeID(value: self.ids.count)
        self.ids[key] = id
        return id
    }
}
