//
//  ArchetypeStaging.swift
//
//
//  Created by rrbox on 2026/07/07.
//

/// spawn staging(`EntityRecordRef`)に保持された値を、要素型を知らない呼び出し側から
/// Archetype のカラムへ挿入できるようにするためのプロトコルです。
///
/// `ComponentRef<T>` のみが適合します。`ImmutableRef`(record 内の Entity エントリ)は
/// 適合させないため、record の map を `ArchetypeInsertable` で列挙すると
/// Entity エントリは自然にスキップされます。
protocol ArchetypeInsertable {
    /// コンポーネント型 `T` を識別するキーです(`ObjectIdentifier(T.self)`)。
    ///
    /// record の map のキー、および `ComponentTypeRegistry` の `typeID(for:)` に
    /// 渡すキーと同じ導出方法で一致させます。
    var componentTypeKey: ObjectIdentifier { get }

    /// 保持する値の型に対応する空カラム(`Column<T>()`)を生成します。
    ///
    /// 新しい Archetype を作成する際のカラムのひな形として使用します。
    func makeColumnPrototype() -> AnyColumn

    /// 保持している現在値を `column` の末尾へ追加します(行の挿入)。
    /// - Parameter column: 追加先のカラム。`Column<T>` である必要があります。
    func appendValue(to column: AnyColumn)
}

extension ComponentRef: ArchetypeInsertable {
    var componentTypeKey: ObjectIdentifier {
        ObjectIdentifier(T.self)
    }

    func makeColumnPrototype() -> AnyColumn {
        Column<T>()
    }

    func appendValue(to column: AnyColumn) {
        // The downcast is confined here as the erased-insertion counterpart of
        // Column.moveRow; `column` must be created via makeColumnPrototype()
        // for the same component type.
        (column as! Column<T>).append(self._value)
    }
}

extension EntityRecordRef {
    /// record の map から `ArchetypeInsertable` に適合する値(コンポーネントの
    /// `ComponentRef`)のみを列挙します。Entity エントリ(`ImmutableRef`)は
    /// 適合しないため含まれません。
    func archetypeInsertables() -> [ArchetypeInsertable] {
        self.map.body.values.compactMap { $0 as? ArchetypeInsertable }
    }
}

extension ArchetypeStorageRef {
    /// staging record(`EntityRecordRef`)の内容を Archetype へ 1 行として挿入し、
    /// entity の所在を `entityIndex` に登録します(設計: スポーン変換の挿入手順)。
    ///
    /// record の map の列挙順は Dictionary 依存で不定なため、insertable を解決済みの
    /// `ComponentTypeID` でソートしてから prototypes / 値の追加を行います。
    /// これにより `ArchetypeKey.ids`(ソート済み)とカラムの並びが常に整列します。
    /// - Parameter record: 挿入する staging record。
    func insert(record: EntityRecordRef) {
        let sortedInsertables = record.archetypeInsertables()
            .map { (id: self.typeID(for: $0.componentTypeKey), insertable: $0) }
            .sorted { $0.id < $1.id }
        let key = ArchetypeKey(sorting: sortedInsertables.map { $0.id })
        let archetype = self.findOrCreate(
            key: key,
            prototypes: sortedInsertables.map { $0.insertable.makeColumnPrototype() }
        )
        archetype.appendRow(entity: record.entity) { columns in
            // columns は key.ids と並行 = sortedInsertables と同順です。
            for (index, element) in sortedInsertables.enumerated() {
                element.insertable.appendValue(to: columns[index])
            }
        }
        self.setLocation(
            EntityLocation(archetype: archetype, row: archetype.entities.count - 1),
            forEntity: record.entity
        )
    }

    /// `spawnStagingQueue` の全 record を挿入し、キューをクリアします。
    ///
    /// spawn 適用フェーズ(World 側)から呼ばれる想定です。
    func applySpawnStaging() {
        for record in self.spawnStagingQueue {
            self.insert(record: record)
        }
        self.spawnStagingQueue.removeAll()
    }
}
