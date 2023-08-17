//
//  WorldInit.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

public extension World {
    convenience init() {
        self.init(entities: [:], worldBuffer: WorldBuffer())
        
        // chunk buffer に chunk entity interface を追加します.
        self.worldBuffer.chunkBuffer.setUpChunkBuffer()
        
        // resource buffer に 時間関係の resource を追加します.
        self.worldBuffer.resourceBuffer.addResource(CurrentTime(value: 0))
        self.worldBuffer.resourceBuffer.addResource(DeltaTime(value: 0))
        
        // world buffer に setup system を保持する領域を確保します.
        self.worldBuffer.systemBuffer.registerSystemRegistry(ofType: SetUpExecute.self)
        
        // world buffer に update system を保持する領域を確保します.
        self.worldBuffer.systemBuffer.registerSystemRegistry(ofType: UpdateExecute.self)
        
        // world buffer に commands の初期値を設定します.
        self.worldBuffer.commandsBuffer.setCommands(Commands())
    }
}
