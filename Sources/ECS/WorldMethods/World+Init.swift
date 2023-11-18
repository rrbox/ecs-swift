//
//  WorldInit.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

public extension World {
    convenience init() {
        self.init(entities: [:], worldBuffer: BufferRef())
        
        // chunk buffer に chunk entity interface を追加します.
        self.worldBuffer.chunkBuffer.setUpChunkBuffer()
        
        // resource buffer に 時間関係の resource を追加します.
        self.worldBuffer.resourceBuffer.addResource(CurrentTime(value: 0))
        self.worldBuffer.resourceBuffer.addResource(DeltaTime(value: 0))
        
        // resrouce buffer に world の情報関係の resource を追加します.
        self.worldBuffer.resourceBuffer.addResource(EntityCount(count: 0))
        
        // world buffer に setup system を保持する領域を確保します.
        self.worldBuffer.systemBuffer.registerSystemRegistry(ofType: SetUpExecute.self)
        
        // world buffer に update system を保持する領域を確保します.
        self.worldBuffer.systemBuffer.registerSystemRegistry(ofType: UpdateExecute.self)
        
        // world buffer に event queue を作成します.
        self.worldBuffer.eventBuffer.setUpEventQueue()
        self.worldBuffer.eventBuffer.setUpCommandsEventQueue(eventOfType: DidSpawnEvent.self)
        self.worldBuffer.eventBuffer.setUpCommandsEventQueue(eventOfType: WillDespawnEvent.self)
        
        // world buffer に spawn/despawn event の streamer を登録します.
        self.addCommandsEventStreamer(eventType: DidSpawnEvent.self)
        self.addCommandsEventStreamer(eventType: WillDespawnEvent.self)
        
        // world buffer に commands の初期値を設定します.
        self.worldBuffer.commandsBuffer.setCommands(Commands())
    }
}
