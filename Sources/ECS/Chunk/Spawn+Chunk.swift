//
//  Spawn+Chunk.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

/// Chunk を種類関係なく格納するためのコンポーネントです.
class ChunkEntityInterface: BufferElement {
    /// entity が spawn されてから component が完全に挿入されるまでの間, entity を queue に保管します.
    ///
    /// Entity が ``Commands/spawn()`` され, ``EntityCommands/addComponent(_:)`` されるまでの間, Entity は実際には Chunk に反映されず,
    var prespawnedEntityQueue = [(Entity, Archetype)]()
    var chunks = [Chunk]()
    
    /// chunk を追加します
    func add(chunk: Chunk) {
        self.chunks.append(chunk)
    }
    
    /// World に entity が追加された時に実行します.
    ///
    /// entity が queue に追加され、フレームの終わりに全ての chunk に entity を反映します.
    func push(entity: Entity, value: Archetype) {
        self.prespawnedEntityQueue.append((entity, value))
    }
    
    /// Spawn 処理された entity を, 実際に chunk に追加します.
    ///
    /// Component が完全に追加された後にこの処理を呼び出すことで, Entity の Component の有無が Chunk に反映されるようになります.
    func applyEntityQueue() {
        for (entity, value) in prespawnedEntityQueue {
            for chunk in chunks {
                chunk.spawn(entity: entity, value: value)
            }
        }
        self.prespawnedEntityQueue = []
    }
    
    /// World から entity が削除される時に実行します.
    ///
    /// フレームの終わりに全ての chunk から entity を削除します.
    func despawn(entity: Entity) {
        for chunk in chunks {
            chunk.despawn(entity: entity)
        }
    }
    
}
