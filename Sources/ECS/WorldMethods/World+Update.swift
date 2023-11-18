//
//  World+Update.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

import Foundation

public struct CurrentTime: ResourceProtocol {
    public let value: TimeInterval
}

public struct DeltaTime: ResourceProtocol {
    public let value: TimeInterval
}

public extension World {
    func update(currentTime: TimeInterval) {
        let currentTimeResource = self.worldStorage.resourceBuffer.resource(ofType: CurrentTime.self)!
        
        self.worldStorage.resourceBuffer.resource(ofType: DeltaTime.self)?.resource = DeltaTime(value: currentTime - currentTimeResource.resource.value)
        
        currentTimeResource.resource = CurrentTime(value: currentTime)
        
        for system in self.worldStorage.systemStorage.systems(.update) {
            system.execute(self.worldStorage)
        }
        
        // world が受信した event を event system に発信します.
        self.applyEventQueue()
        
        self.applyCommands()
        
        // will despawn event を配信します.
        self.applyCommandsEventQueue(eventOfType: WillDespawnEvent.self)
        
        // apply commands の際に push された entity を chunk に割り振ります.
        self.worldStorage.chunkStorage.applyEntityQueue()
        
        // Did Spawn event を event system に発信します.
        self.applyCommandsEventQueue(eventOfType: DidSpawnEvent.self)
    }
}
