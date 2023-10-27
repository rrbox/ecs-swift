//
//  ChunkStorage.swift
//
//
//  Created by rrbox on 2023/08/11.
//

/// Chunk を種類別で格納します
final public class ChunkStorage {
    class ChunkRegistry<ChunkType: Chunk>: WorldStorageElement {
        let chunk: ChunkType
        
        init(chunk: ChunkType) {
            self.chunk = chunk
        }
    }
    
    let buffer: WorldStorageRef
    init(buffer: WorldStorageRef) {
        self.buffer = buffer
    }
    
    public func chunk<ChunkType: Chunk>(ofType type: ChunkType.Type) -> ChunkType? {
        self.buffer.map.valueRef(ofType: ChunkRegistry<ChunkType>.self)?.body.chunk
    }
}

public extension WorldStorageRef {
    var chunkStorage: ChunkStorage {
        ChunkStorage(buffer: self)
    }
}
