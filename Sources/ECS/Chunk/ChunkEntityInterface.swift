//
//  ChunkEntityInterface.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

class _ChunkBox {
    func spawn(entity: Entity, entityRecord: EntityRecordRef) async {}
    func despawn(entity: Entity) async {}
    func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) async {}
}

class ChunkBox<T: Chunk>: _ChunkBox {
    let chunk: T
    
    init(chunk: T) {
        self.chunk = chunk
    }
    
    override func spawn(entity: Entity, entityRecord: EntityRecordRef) async {
        await self.chunk.spawn(entity: entity, entityRecord: entityRecord)
    }
    
    override func despawn(entity: Entity) async {
        await self.chunk.despawn(entity: entity)
    }
    
    override func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) async {
        await self.chunk.applyCurrentState(entityRecord, forEntity: entity)
    }
}

/// Chunk を種類関係なく格納するためのコンポーネントです.
///
/// Entity の変更を全ての Chunk に反映させる目的で使用されます.
actor ChunkEntityInterface: WorldStorageElement {
    /// entity が spawn されてから component が完全に挿入されるまでの間, entity を queue に保管します.
    ///
    /// Entity が ``Commands/spawn()`` され, ``EntityCommands/addComponent(_:)`` されるまでの間, Entity は実際には Chunk に反映されず,
    var prespawnedEntityQueue = [(Entity, EntityRecordRef)]()
    var chunks = [_ChunkBox]()
    
    /// chunk を追加します
    func add<T: Chunk>(chunk: T) {
        self.chunks.append(ChunkBox(chunk: chunk))
    }
    
    /// World に entity が追加された時に実行します.
    ///
    /// entity が queue に追加され、フレームの終わりに全ての chunk に entity を反映します.
    func push(entity: Entity, entityRecord: EntityRecordRef) {
        self.prespawnedEntityQueue.append((entity, entityRecord))
    }
    
    /// Spawn 処理された entity を, 実際に chunk に追加します.
    ///
    /// Component が完全に追加された後にこの処理を呼び出すことで, Entity の Component の有無が Chunk に反映されるようになります.
    func applyEntityQueue() async {
        for (entity, entityRecord) in prespawnedEntityQueue {
            for chunk in self.chunks {
                await chunk.spawn(entity: entity, entityRecord: entityRecord)
            }
        }
        self.prespawnedEntityQueue = []
    }
    
    /// World から entity が削除される時に実行します.
    ///
    /// フレームの終わりに全ての chunk から entity を削除します.
    func despawn(entity: Entity) async {
        for chunk in self.chunks {
            await chunk.despawn(entity: entity)
        }
    }
    
    func applyCurrentState(_ entityRecord: EntityRecordRef, forEntity entity: Entity) async {
        for chunk in self.chunks {
            await chunk.applyCurrentState(entityRecord, forEntity: entity)
        }
    }
    
}
