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

        let systemStorage = self.worldStorage.systemStorage
        let eventStorage = self.worldStorage.eventStorage

        // world storage に system を保持する領域を確保します.
        systemStorage.registerSystemRegistry()

        // world buffer に setup system を保持する領域を確保します.
        systemStorage.insertSchedule(.preStartUp)
        systemStorage.insertSchedule(.startUp)
        systemStorage.insertSchedule(.postStartUp)

        // world buffer に update system を保持する領域を確保します. 
        systemStorage.insertSchedule(.preUpdate)
        systemStorage.insertSchedule(.update)
        systemStorage.insertSchedule(.postUpdate)

        // state storage に schedule 管理をするための準備をします.
        self.worldStorage.stateStorage.setUp()

        // world buffer に event queue を作成します.
        eventStorage.setUpEventQueue()
        eventStorage.setUpCommandsEventQueue(eventOfType: DidSpawnEvent.self)
        eventStorage.setUpCommandsEventQueue(eventOfType: WillDespawnEvent.self)

        // world buffer に spawn/despawn event の streamer を登録します.
        self.addCommandsEventStreamer(eventType: DidSpawnEvent.self)
        self.addCommandsEventStreamer(eventType: WillDespawnEvent.self)

        // world に一番最初のフレームで実行されるシステムを追加します.
        systemStorage.addSystem(.preStartUp, System(preUpdateSystemFirstFrameSystem(commands:)))
        systemStorage.addSystem(.startUp, System(updateSystemFirstFrameSystem(commands:)))
        systemStorage.addSystem(.postStartUp, System(postUpdateSystemFirstFrameSystem(commands:)))
    }
}
