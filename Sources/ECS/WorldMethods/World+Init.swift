//
//  WorldInit.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

public extension World {
    convenience init() {
        self.init(worldStorage: WorldStorageRef())
        
        // chunk buffer に chunk entity interface を追加します.
        self.worldStorage.chunkStorage.setUpChunkBuffer()
        
        // resource buffer に 時間関係の resource を追加します.
        self.worldStorage.resourceBuffer.addResource(CurrentTime(value: 0))
        self.worldStorage.resourceBuffer.addResource(DeltaTime(value: 0))
        
        // resrouce buffer に world の情報関係の resource を追加します.
        self.worldStorage.resourceBuffer.addResource(EntityCount(count: 0))
        
        // world storage に system を保持する領域を確保します.
        self.worldStorage.systemStorage.registerSystemRegistry()
        
        // world buffer に setup system を保持する領域を確保します.
        self.worldStorage.systemStorage.insertSchedule(.startUp)
        
        // world buffer に update system を保持する領域を確保します.
        self.worldStorage.systemStorage.insertSchedule(.firstFrame)
        self.worldStorage.systemStorage.insertSchedule(.update)
        
        // state storage に schedule 管理をするための準備をします.
        self.worldStorage.stateStorage.setUp()
        
        // world buffer に event queue を作成します.
        self.worldStorage.eventStorage.setUpEventQueue()
        self.worldStorage.eventStorage.setUpCommandsEventQueue(eventOfType: DidSpawnEvent.self)
        self.worldStorage.eventStorage.setUpCommandsEventQueue(eventOfType: WillDespawnEvent.self)
        
        // world buffer に spawn/despawn event の streamer を登録します.
        self.addCommandsEventStreamer(eventType: DidSpawnEvent.self)
        self.addCommandsEventStreamer(eventType: WillDespawnEvent.self)
        
        // world buffer に commands の初期値を設定します.
        self.worldStorage.commandsStorage.setCommands(Commands())
        
        // world に一番最初のフレームで実行されるシステムを追加します.
        self.worldStorage.systemStorage.addSystem(.firstFrame, System(firstFrameSystem(commands:)))
    }
}
