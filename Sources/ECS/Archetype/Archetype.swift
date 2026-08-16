//
//  Archetype.swift
//
//
//  Created by rrbox on 2026/07/06.
//

/// Archetype を識別するキーです。コンポーネント型 ID の集合を表します。
///
/// `ids` は常にソート済みであることを不変条件とします。イニシャライザが
/// 入力をソートするため、同じ型集合からは入力順によらず同一のキーが生成されます。
struct ArchetypeKey: Hashable {
    /// ソート済みのコンポーネント型 ID 配列です。
    let ids: [ComponentTypeID]

    /// 型 ID 配列をソートしてキーを生成します。
    /// - Parameter ids: コンポーネント型 ID 配列。順序は問いません。
    init(sorting ids: [ComponentTypeID]) {
        self.ids = ids.sorted()
    }
}

/// 同じコンポーネント型集合を持つ entity 群を SoA レイアウトで保持するテーブルです。
///
/// `entities` が行番号 → entity の対応を持ち、`columns` は `key.ids` と並行な
/// 型消去カラム配列です。行操作は必ず `entities` と全カラムを同期して行い、
/// `entities.count == columns[i].count`(全 i)を不変条件とします(デバッグビルドの
/// assertion で検出)。
///
/// `addEdges` / `removeEdges` は archetype graph の辺(コンポーネント追加・削除による
/// 移動先)で、本型では保持のみを担い、構築はストレージ側で行います。
/// 辺は強参照で保持しますが、Archetype はストレージと同寿命であり回収は行わないため
/// 許容されます(設計方針)。
final class Archetype {
    /// この Archetype の型集合キーです。
    let key: ArchetypeKey

    /// 行番号 → entity の対応表です。
    var entities = [Entity]()

    /// `key.ids` と並行なカラム配列です。
    var columns: [AnyColumn]

    /// コンポーネント型 ID → `columns` 内インデックスの索引です。
    var columnIndexByType: [ComponentTypeID: Int]

    /// コンポーネント追加時の移動先 Archetype への辺です(archetype graph)。
    var addEdges = [ComponentTypeID: Archetype]()

    /// コンポーネント削除時の移動先 Archetype への辺です(archetype graph)。
    var removeEdges = [ComponentTypeID: Archetype]()

    /// キーと、`key.ids` に並行なカラム配列から Archetype を生成します。
    /// - Parameters:
    ///   - key: 型集合キー。
    ///   - columns: `key.ids` と同数・同順のカラム配列。
    init(key: ArchetypeKey, columns: [AnyColumn]) {
        assert(key.ids.count == columns.count, "Archetype columns must be parallel to key.ids.")
        self.key = key
        self.columns = columns
        var columnIndexByType = [ComponentTypeID: Int]()
        for (index, id) in key.ids.enumerated() {
            columnIndexByType[id] = index
        }
        self.columnIndexByType = columnIndexByType
    }

    /// 指定した型 ID のカラムを返します。
    /// - Parameter id: コンポーネント型 ID。
    /// - Returns: 対応するカラム。この Archetype に含まれない型の場合は nil。
    func column(of id: ComponentTypeID) -> AnyColumn? {
        guard let index = self.columnIndexByType[id] else { return nil }
        return self.columns[index]
    }

    /// 行を追加します。カラムへの値の追加は呼び出し側が `fillColumns` 内で行います。
    /// - Parameters:
    ///   - entity: 追加する行の entity。
    ///   - fillColumns: `key.ids` と並行なカラム配列を受け取り、全カラムへ 1 要素ずつ追加するクロージャ。
    func appendRow(entity: Entity, fillColumns: ([AnyColumn]) -> Void) {
        self.entities.append(entity)
        fillColumns(self.columns)
        self.assertInvariant()
    }

    /// 指定した行を swap-remove し、穴を埋めるために移動してきた entity を返します。
    ///
    /// `entities` と全カラムを同期して swap-remove します。戻り値は移動後に `row` に
    /// 位置する entity で、呼び出し側の entity 所在情報(entityIndex)の補正に使用します。
    /// - Parameter row: 削除する行のインデックス。
    /// - Returns: `row` を埋めるために末尾から移動してきた entity。削除した行が末尾だった場合は nil。
    func swapRemoveRow(_ row: Int) -> Entity? {
        let lastRow = self.entities.count - 1
        self.entities.swapAt(row, lastRow)
        self.entities.removeLast()
        for column in self.columns {
            column.swapRemoveRow(row)
        }
        self.assertInvariant()
        return row < lastRow ? self.entities[row] : nil
    }

    /// `entities.count == columns[i].count`(全 i)の不変条件をデバッグビルドで検証します。
    ///
    /// 行操作を Archetype 外(searched entity 経路の行移動など)で行った場合にも
    /// 検証できるよう internal にしています。
    func assertInvariant() {
        assert(
            self.columns.allSatisfy { $0.count == self.entities.count },
            "Archetype row count invariant violated."
        )
    }
}
