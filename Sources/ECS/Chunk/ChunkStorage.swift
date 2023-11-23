//
//  ChunkStorage.swift
//
//
//  Created by rrbox on 2023/08/11.
//

extension Chunk: WorldStorageElement {
    
}

/// Chunk を種類別で格納します
final public class ChunkStorage {
    let buffer: WorldStorageRef
    init(buffer: WorldStorageRef) {
        self.buffer = buffer
    }
    
    public func chunk<ChunkType: Chunk>(ofType type: ChunkType.Type) -> ChunkType? {
        self.buffer.map.valueRef(ofType: ChunkType.self)?.body
    }
}

public extension WorldStorageRef {
    var chunkStorage: ChunkStorage {
        ChunkStorage(buffer: self)
    }
}
