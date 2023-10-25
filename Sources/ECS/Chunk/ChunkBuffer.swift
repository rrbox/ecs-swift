//
//  ChunkBuffer.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

/// Chunk を種類別で格納します
final public class ChunkBuffer {
    class ChunkRegistry<ChunkType: Chunk>: WorldStorageElement {
        let chunk: ChunkType
        
        init(chunk: ChunkType) {
            self.chunk = chunk
        }
    }
    
    let buffer: BufferRef
    init(buffer: BufferRef) {
        self.buffer = buffer
    }
    
    public func chunk<ChunkType: Chunk>(ofType type: ChunkType.Type) -> ChunkType? {
        self.buffer.map.valueRef(ofType: ChunkRegistry<ChunkType>.self)?.body.chunk
    }
}

public extension BufferRef {
    var chunkBuffer: ChunkBuffer {
        ChunkBuffer(buffer: self)
    }
}
