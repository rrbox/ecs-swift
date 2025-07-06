//
//  ChunkEntityInterface.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

/// Chunk を種類関係なく格納するためのコンポーネントです.
///
/// Entity の変更を全ての Chunk に反映させる目的で使用されます.
class ChunkEntityInterface: ChunkStorageElement {
    /// entity が spawn されてから component が完全に挿入されるまでの間, entity を queue に保管します.
    ///
    /// Entity が ``Commands/spawn()`` され, ``EntityCommands/addComponent(_:)`` されるまでの間, Entity は実際には Chunk に反映されず,
    var prespawnedEntityQueue = [EntityRecordRef]()
    var updatedEntityQueue = [EntityRecordRef]()
    var chunks = [Chunk]()

    /// chunk を追加します
    func add(chunk: Chunk) {
        self.chunks.append(chunk)
    }

    /// World に entity が追加された時に実行します.
    ///
    /// entity が queue に追加され、フレームの終わりに全ての chunk に entity を反映します.
    func pushSpawned(entityRecord: EntityRecordRef) {
        self.prespawnedEntityQueue.append(entityRecord)
    }

    /// Spawn 処理された entity を, 実際に chunk に追加します.
    ///
    /// Component が完全に追加された後にこの処理を呼び出すことで, Entity の Component の有無が Chunk に反映されるようになります.
    func applySpawnedEntityQueue() {
        for entityRecord in self.prespawnedEntityQueue {
            for chunk in self.chunks {
                chunk.spawn(entityRecord: entityRecord)
            }
        }
        self.prespawnedEntityQueue = []
    }

    /// World から entity が削除される時に実行します.
    ///
    /// フレームの終わりに全ての chunk から entity を削除します. ← これ嘘では
    func despawn(entity: Entity) {
        for chunk in self.chunks {
            chunk.despawn(entity: entity)
        }
    }

    /// World 内にすでに存在している entity の component を追加/削除する制御
    ///
    /// ``Commands/entity(_:)`` で検索された entity のみが対象です.
    func pushUpdated(entityRecord: EntityRecordRef) {
        self.updatedEntityQueue.append(entityRecord)
    }

    func applyUpdatedEntityQueue() {
        for entityRecord in self.updatedEntityQueue {
            for chunk in self.chunks {
                chunk.applyCurrentState(entityRecord)
            }
        }
        self.updatedEntityQueue = []
    }

}
