//
//  Column.swift
//
//
//  Created by rrbox on 2026/07/06.
//

/// Archetype の 1 コンポーネント型分の列(SoA カラム)を型消去して扱うためのプロトコルです。
///
/// Archetype 間のエンティティ移動(行の移動)を、要素型を知らない呼び出し側から
/// 実行できるようにします。要素型へのダウンキャストは `moveRow(_:to:)` の実装内部に
/// 閉じ込め、呼び出し側にはキャストを持ち込みません。
protocol AnyColumn: AnyObject {
    /// カラムが保持する行数です。
    var count: Int { get }

    /// 同じ要素型の空カラムを生成します(新しい Archetype のカラム作成用)。
    func makeEmpty() -> AnyColumn

    /// 指定した行の値を `target` の末尾へ移動し、自身からは swap-remove で取り除きます。
    /// - Parameters:
    ///   - row: 移動する行のインデックス。
    ///   - target: 移動先のカラム。自身と同じ要素型である必要があります。
    func moveRow(_ row: Int, to target: AnyColumn)

    /// 指定した行を swap-remove(末尾要素と入れ替えて末尾を削除)で破棄します。
    /// - Parameter row: 破棄する行のインデックス。
    func swapRemoveRow(_ row: Int)
}

/// コンポーネント型 `C` の値を連続配置で保持する SoA カラムです。
///
/// `Array` の値セマンティクスに乗ることで、クラス参照を含む非トリビアルな
/// コンポーネント(例: `Graphic<Node>` のような型)も安全に保持・移動できます。
/// Query のイテレーションでは `&column.data[i]` の形で要素へ直接アクセスします。
final class Column<C: QueryTarget>: AnyColumn {
    /// カラムの実データです。行番号がそのまま添字になります。
    var data = [C]()

    var count: Int {
        self.data.count
    }

    /// 末尾に値を追加します(新しい行の挿入)。
    /// - Parameter value: 追加するコンポーネントの値。
    func append(_ value: C) {
        self.data.append(value)
    }

    func makeEmpty() -> AnyColumn {
        Column<C>()
    }

    func moveRow(_ row: Int, to target: AnyColumn) {
        // 要素型へのダウンキャストはここにのみ存在させ、呼び出し側には持ち込みません。
        let target = target as! Column<C>
        target.data.append(self.data[row])
        self.swapRemoveRow(row)
    }

    func swapRemoveRow(_ row: Int) {
        // swapAt(row, row) は許容されるため、末尾行の削除もこの実装で成立します。
        self.data.swapAt(row, self.data.count - 1)
        self.data.removeLast()
    }
}
