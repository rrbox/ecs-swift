//
//  ChunkBuffer.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

import Foundation

/// Chunk を種類別で格納します
class ChunkBuffer {
    class ChunkRegistry<ChunkType: Chunk>: BufferElement {
        let chunk: ChunkType
        init(chunk: ChunkType) {
            self.chunk = chunk
            super.init()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    let buffer: Buffer
    init(buffer: Buffer) {
        self.buffer = buffer
    }
    
    func chunk<ChunkType: Chunk>(ofType type: ChunkType.Type) -> ChunkType? {
        self.buffer.component(ofType: ChunkRegistry<ChunkType>.self)?.chunk
    }
}

extension WorldBuffer {
    var chunkBuffer: ChunkBuffer {
        ChunkBuffer(buffer: self)
    }
}
