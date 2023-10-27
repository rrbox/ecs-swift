//
//  World+Update.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

import Foundation

public extension World {
    func update(currentTime: TimeInterval) {
        let currentTimeResource = self.worldBuffer.resourceBuffer.resource(ofType: CurrentTime.self)!
        
        self.worldBuffer.resourceBuffer.resource(ofType: DeltaTime.self)?.resource = DeltaTime(value: currentTime - currentTimeResource.resource.value)
        
        currentTimeResource.resource = CurrentTime(value: currentTime)
        
        for system in self.worldBuffer.systemBuffer.systems(ofType: UpdateExecute.self) {
            system.update(worldBuffer: self.worldBuffer)
        }
        
        // world が受信した event を event system に発信します.
        self.applyEventQueue()
        
        self.applyCommands()
        
        // will despawn event を配信します.
        self.applyCommandsEventQueue(eventOfType: WillDespawnEvent.self)
        
        // apply commands の際に push された entity を chunk に割り振ります.
        self.worldBuffer.chunkStorage.applyEntityQueue()
        
        // Did Spawn event を event system に発信します.
        self.applyCommandsEventQueue(eventOfType: DidSpawnEvent.self)
    }
}
