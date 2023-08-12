//
//  Spawn+Chunk.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

/// Chunk を種類関係なく格納するためのコンポーネントです.
class ChunkEntityInterface {
    class Command {
        func apply(chunks: [Chunk]) {
            
        }
    }
//    var entityQueue = [(Entity, Archetype)]()
    var spawnEntityQueue = [(Entity, Archetype)]()
    var despawnEntityQueue = [Entity]()
    var chunks = [Chunk]()
    
    /// World に entity が追加された時に実行します.
    ///
    /// entity が queue に追加され、フレームの終わりに全ての chunk に entity を反映します.
    func spawn(entity: Entity, value: Archetype) {
        self.spawnEntityQueue.append((entity, value))
    }
    
    /// World から entity が削除される時に実行します.
    ///
    /// フレームの終わりに全ての chunk から entity をさ削除します.
    func despawn(_ entity: Entity) {
        self.despawnEntityQueue.append(entity)
    }
    
    /// フレーム終了時、 enqueue された entity を全ての chunk に追加します.
    func applyEntityQueue() {
        for (entity, value) in self.spawnEntityQueue {
            for chunk in self.chunks {
                chunk.spawn(entity: entity, value: value)
            }
        }
        for entity in self.despawnEntityQueue {
            for chunk in self.chunks {
                chunk.despawn(entity: entity)
            }
        }
        self.spawnEntityQueue = []
        self.despawnEntityQueue = []
    }
    
}
