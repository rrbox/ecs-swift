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
        worldStorage.chunkStorageRef.setUpChunkBuffer()

        // resource buffer に 時間関係の resource を追加します.
        worldStorage.resourceStorage.addResource(CurrentTime(value: 0))
        worldStorage.resourceStorage.addResource(DeltaTime(value: 0))

        // resrouce buffer に world の情報関係の resource を追加します.
        worldStorage.resourceStorage.addResource(EntityCount(count: 0))

        // world storage に system を保持する領域を確保します.
        worldStorage.systemStorage.registerSystemRegistry()

        // world buffer に setup system を保持する領域を確保します.
        worldStorage.systemStorage.insertSchedule(.preStartUp)
        worldStorage.systemStorage.insertSchedule(.startUp)
        worldStorage.systemStorage.insertSchedule(.postStartUp)

        // world buffer に update system を保持する領域を確保します. 
        worldStorage.systemStorage.insertSchedule(.preUpdate)
        worldStorage.systemStorage.insertSchedule(.update)
        worldStorage.systemStorage.insertSchedule(.postUpdate)

        // world buffer に removed system を保持する領域を確保します.
        worldStorage.systemStorage.insertSchedule(.removed)

        // state storage に schedule 管理をするための準備をします.
        worldStorage.stateStorage.setUp()

        // world buffer に event queue を作成します.
        worldStorage.eventStorage.registerEventQueues()

        // world buffer に spawn event の streamer を登録します.
        addEventStreamer(eventType: Spawned.self)
        addRemovedEventStreamer()

        // world に一番最初のフレームで実行されるシステムを追加します.
        worldStorage.systemStorage.addSystem(.preStartUp, System(preUpdateSystemFirstFrameSystem(commands:)))
        worldStorage.systemStorage.addSystem(.startUp, System(updateSystemFirstFrameSystem(commands:)))
        worldStorage.systemStorage.addSystem(.postStartUp, System(postUpdateSystemFirstFrameSystem(commands:)))
    }
}
