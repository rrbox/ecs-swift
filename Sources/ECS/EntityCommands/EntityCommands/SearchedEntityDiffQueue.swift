//
//  SearchedEntityDiffQueue.swift
//
//
//  Created by rrbox on 2026/07/08.
//

/// searched entity(`commands.entity(_)`)への 1 コンポーネント分の変更差分です。
///
/// archetype storage ON の World では、既存 entity への変更は record 直接操作の
/// 代わりにこの差分として蓄積され、flush 時に Archetype 移動として適用されます
/// (折衷方針の searched 側、要件 3-3)。
enum ComponentDiff {
    /// コンポーネントの追加です。追加する値そのもの(`ComponentRef<C>`)を保持します。
    /// 旧経路の `AddComponent<C>` 相当です。
    case add(ArchetypeInsertable)

    /// コンポーネントの削除です。削除する型のキーを保持します。
    /// 旧経路の `RemoveComponent<C>` 相当です。
    case remove(ObjectIdentifier)

    /// この差分が対象とするコンポーネント型のキーです。「後勝ち」正規化の
    /// 同一型判定に使用します。
    var componentTypeKey: ObjectIdentifier {
        switch self {
        case .add(let insertable):
            return insertable.componentTypeKey
        case .remove(let key):
            return key
        }
    }
}

/// searched entity への変更差分を蓄積するトランザクションキューです
/// (archetype storage ON 専用。旧経路の `SearchedEntityCommandQueue` 相当)。
///
/// `runCommand(in:)`(applyEnityTransactions)では蓄積のみを行い、実際の
/// Archetype 移動は applyCommandsPhase 末尾の diff 適用で行われます
/// (design.md システムフロー: 「diff queue は蓄積のみ」)。
final class SearchedEntityDiffQueue: EntityTransaction {
    /// 変更対象の entity です。
    let entity: Entity

    /// 蓄積された差分です。空のままなら flush 時に何も起きません(要件 3-4)。
    var diffs = [ComponentDiff]()

    init(entity: Entity) {
        self.entity = entity
    }

    /// 同一型への重複差分を「後勝ち」で正規化した差分列を返します(要件 3-3)。
    ///
    /// 同じ型キーが複数回現れた場合、最後の差分のみが残ります
    /// (add → remove は remove、remove → add は add)。残った差分の位置は
    /// 最初の出現位置を保ちますが、正規化後は型キーが互いに異なるため
    /// 適用結果は順序に依存しません。
    func normalizedDiffs() -> [ComponentDiff] {
        var result = [ComponentDiff]()
        var indexByKey = [ObjectIdentifier: Int]()
        for diff in self.diffs {
            if let index = indexByKey[diff.componentTypeKey] {
                result[index] = diff
            } else {
                indexByKey[diff.componentTypeKey] = result.count
                result.append(diff)
            }
        }
        return result
    }

    /// diff queue を `ArchetypeStorageRef.diffQueues` へ蓄積します。
    ///
    /// 差分が空の場合は何も積みません: `commands.entity(e)` だけを呼んで
    /// 変更を加えなかった場合、flush で Query 再評価を含む一切の処理が
    /// 発生しません(要件 3-4)。
    override func runCommand(in world: World) {
        guard !self.diffs.isEmpty else { return }
        world.worldStorage.archetypeStorageRef?.diffQueues.append(self)
    }
}

// MARK: - flush 適用 (archetype 移動)

extension ArchetypeStorageRef {
    /// `diffQueues` の全 diff queue を適用し、キューをクリアします。
    ///
    /// applyCommandsPhase 末尾(commands 適用後)から呼ばれます。旧経路の
    /// `applyUpdatedEntityQueue` と同じ位置で実行することで適用順序を現行踏襲と
    /// します(要件 1-5)。
    func applyDiffQueues() {
        // 適用中(findOrCreate)の observer 通知で diffQueues に触れる実装はないため
        // snapshot は不要ですが、apply 中の再入を避けるため先に drain します。
        let queues = self.diffQueues
        self.diffQueues.removeAll()
        for queue in queues {
            self.apply(diffQueue: queue)
        }
    }

    /// diff queue 1 件を entity の Archetype 移動として適用します。
    ///
    /// 手順(design.md「SearchedEntityDiffQueue」適用): 後勝ち正規化 → `entityIndex`
    /// 検索(不在は silent skip)→ 差分の分類(既存型への add は行の値上書き、
    /// 不在型の remove は no-op)→ 目標 Archetype の解決(edge / byKey)→ 共通カラムの
    /// `moveRow` + 追加分の `appendValue`(削除分は移動対象外)→ swap-remove の filler
    /// 補正 → 自身の所在更新。
    private func apply(diffQueue: SearchedEntityDiffQueue) {
        let diffs = diffQueue.normalizedDiffs()

        // 空 diff は何もしません(要件 3-4)。
        guard !diffs.isEmpty else { return }

        // despawn 済み・世代不一致の entity への適用は現行の searched 挙動に合わせて
        // silent skip します(design.md エラーハンドリング)。
        guard let location = self.location(of: diffQueue.entity) else { return }
        let source = location.archetype

        // 差分を「構造変更」と「値の上書き」に分類します。正規化済みのため
        // 同一型の差分は 1 件しか現れません。
        var newAdds = [(id: ComponentTypeID, insertable: ArchetypeInsertable)]()
        var removedIDs = Set<ComponentTypeID>()
        for diff in diffs {
            let id = self.typeID(for: diff.componentTypeKey)
            switch diff {
            case .add(let insertable):
                if let column = source.column(of: id) {
                    // 既に持っている型への add は Archetype 移動を伴わない行の値上書きです。
                    // 移動が発生する場合も、上書き後の値が moveRow で移動先へ運ばれます。
                    insertable.writeValue(at: location.row, in: column)
                } else {
                    newAdds.append((id: id, insertable: insertable))
                }
            case .remove:
                // 持っていない型の remove は no-op です。
                if source.columnIndexByType[id] != nil {
                    removedIDs.insert(id)
                }
            }
        }

        // 型集合が変わらない場合(上書きのみ・全て no-op)は移動しません。
        guard !(newAdds.isEmpty && removedIDs.isEmpty) else { return }

        let target = self.resolveTargetArchetype(from: source, adding: newAdds, removing: removedIDs)

        // カラムの行移動: 共通型は moveRow(swap-remove + 移動先末尾へ追加)、
        // 削除型は swap-remove のみ(値は破棄)、追加型は移動先へ append します。
        let row = location.row
        for (index, id) in source.key.ids.enumerated() {
            let column = source.columns[index]
            if removedIDs.contains(id) {
                column.swapRemoveRow(row)
            } else {
                // target は「source − removes + adds」の型集合なので必ずカラムがあります。
                column.moveRow(row, to: target.column(of: id)!)
            }
        }
        for element in newAdds {
            element.insertable.appendValue(to: target.column(of: element.id)!)
        }

        // entities 配列をカラムと同期して swap-remove し、移動先へ追加します。
        let lastRow = source.entities.count - 1
        source.entities.swapAt(row, lastRow)
        source.entities.removeLast()
        target.entities.append(diffQueue.entity)
        source.assertInvariant()
        target.assertInvariant()

        // swap-remove で row を埋めた entity(filler)の所在を補正します。
        // insert は dedupe せず stale エントリが残るため update を使います
        // (tasks.md Implementation Notes)。
        if row < lastRow {
            let filler = source.entities[row]
            self.entityIndex.update(forEntity: filler) { fillerLocation in
                fillerLocation.row = row
            }
        }

        // 移動した entity 自身の所在を更新します(同上の理由で insert ではなく update)。
        let newLocation = EntityLocation(archetype: target, row: target.entities.count - 1)
        self.entityIndex.update(forEntity: diffQueue.entity) { location in
            location = newLocation
        }
    }

    /// 目標 Archetype を解決します。
    ///
    /// 単一コンポーネントの構造変更は archetype graph の辺(`addEdges` / `removeEdges`)で
    /// O(1) 解決し、辺が未構築の場合は `byKey` / `findOrCreate` で解決してから辺を
    /// 双方向にキャッシュします(design.md: edge はこのときキャッシュ、要件 5-1)。
    /// 複数差分の複合移動は辺で表現できないため常に `byKey` / `findOrCreate` で解決します。
    private func resolveTargetArchetype(
        from source: Archetype,
        adding newAdds: [(id: ComponentTypeID, insertable: ArchetypeInsertable)],
        removing removedIDs: Set<ComponentTypeID>
    ) -> Archetype {
        // 単一構造変更: 辺キャッシュの参照。
        if removedIDs.isEmpty, newAdds.count == 1, let cached = source.addEdges[newAdds[0].id] {
            return cached
        }
        if newAdds.isEmpty, removedIDs.count == 1, let cached = source.removeEdges[removedIDs.first!] {
            return cached
        }

        // byKey / findOrCreate フォールバック。
        let targetIDs = source.key.ids.filter { !removedIDs.contains($0) } + newAdds.map { $0.id }
        let key = ArchetypeKey(sorting: targetIDs)
        let target: Archetype
        if let existing = self.byKey[key] {
            target = existing
        } else {
            // 新規生成時のみ prototypes を構築します。共通型は source のカラムから、
            // 追加型は insertable から、key.ids と並行になるよう解決します。
            var prototypeByID = [ComponentTypeID: AnyColumn]()
            for (index, id) in source.key.ids.enumerated() where !removedIDs.contains(id) {
                prototypeByID[id] = source.columns[index].makeEmpty()
            }
            for element in newAdds {
                prototypeByID[element.id] = element.insertable.makeColumnPrototype()
            }
            // findOrCreate は生成時に observers(Query)へ通知するため、
            // 新しい Archetype は ON の Query に自動的にマッチします。
            target = self.findOrCreate(key: key, prototypes: key.ids.map { prototypeByID[$0]! })
        }

        // 解決した辺のキャッシュ(単一構造変更のみ。双方向に張ります)。
        if removedIDs.isEmpty, newAdds.count == 1 {
            source.addEdges[newAdds[0].id] = target
            target.removeEdges[newAdds[0].id] = source
        } else if newAdds.isEmpty, removedIDs.count == 1 {
            let id = removedIDs.first!
            source.removeEdges[id] = target
            target.addEdges[id] = source
        }
        return target
    }
}
