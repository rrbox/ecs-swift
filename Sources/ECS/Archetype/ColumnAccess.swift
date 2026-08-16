//
//  ColumnAccess.swift
//
//
//  Created by rrbox on 2026/07/07.
//

/// Query のターゲット型 `C` を、Archetype 内のデータ供給元へ解決した結果です(要件 2-6)。
///
/// マッチ時(`resolve(in:storage:)`)に 1 回だけダウンキャストしてカラムを保持し、
/// イテレーション時にはキャストなしで要素へアクセスできるようにします。
///
/// `Entity` ターゲットは特別扱いされます: Archetype に `Entity` のカラムは存在しないため、
/// `.entity` として解決し、読み出しは `archetype.entities` から供給します。書き込みは
/// 破棄されます(現行 `ImmutableRef` の set no-op と同等のセマンティクス)。
enum ColumnAccess<C: QueryTarget> {
    /// 対象型のカラムを保持するケースです。resolve 時に 1 回だけダウンキャストされます。
    case column(Column<C>)

    /// `C == Entity` のケースです。`archetype.entities` から値を供給します。
    case entity

    /// `C` が `Entity` ターゲットかどうかを返します。
    static var isEntity: Bool { C.self == Entity.self }

    /// Archetype 内で `C` のデータ供給元を解決します。
    ///
    /// - `C == Entity` の場合は常に `.entity` を返します(Entity カラムは存在しないため)。
    /// - それ以外は `storage` で型 ID を引き、Archetype 内の対応カラムを `.column` として返します。
    /// - Parameters:
    ///   - archetype: 解決対象の Archetype。
    ///   - storage: 型 ID の採番レジストリを持つストレージ。
    /// - Returns: 解決結果。Archetype が型 `C` を含まない場合は nil(マッチしない)。
    static func resolve(in archetype: Archetype, storage: ArchetypeStorageRef) -> ColumnAccess<C>? {
        if self.isEntity {
            return .entity
        }
        let typeID = storage.typeID(for: ObjectIdentifier(C.self))
        guard let anyColumn = archetype.column(of: typeID) else { return nil }
        // 設計方針: 要素型へのダウンキャストはマッチ時のこの 1 回のみ。
        guard let column = anyColumn as? Column<C> else {
            assertionFailure("Column type mismatch: expected Column<\(C.self)>.")
            return nil
        }
        return .column(column)
    }

    /// 保持しているカラムを返します。`.entity` の場合は nil です。
    ///
    /// Query のイテレーション(`for i in 0..<count { f(&column.data[i]) }`)で
    /// 要素へ直接アクセスするための公開経路です。
    var columnRef: Column<C>? {
        switch self {
        case .column(let column):
            return column
        case .entity:
            return nil
        }
    }

    /// 指定した行の値を読み出します。
    ///
    /// `.column` はカラムの実データから、`.entity` は `archetype.entities` から供給します。
    /// - Parameters:
    ///   - row: 行番号。
    ///   - archetype: `.entity` の供給元となる Archetype。resolve に渡したものと同一である必要があります。
    /// - Returns: 行の値。
    func value(at row: Int, in archetype: Archetype) -> C {
        switch self {
        case .column(let column):
            return column.data[row]
        case .entity:
            // isEntity(C.self == Entity.self)が保証されているため、このキャストは常に成功します。
            return archetype.entities[row] as! C
        }
    }

    /// 指定した行へ値を書き込みます。
    ///
    /// `.entity` への書き込みは破棄されます(現行 `ImmutableRef` の set no-op と同等)。
    /// - Parameters:
    ///   - value: 書き込む値。
    ///   - row: 行番号。
    func setValue(_ value: C, at row: Int) {
        switch self {
        case .column(let column):
            column.data[row] = value
        case .entity:
            break
        }
    }
}
