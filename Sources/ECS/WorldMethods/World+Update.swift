//
//  World+Update.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

import Foundation

public extension World {
    func update(currentTime: TimeInterval) {
        let lastTime = self.worldBuffer.resourceBuffer.resource(ofType: CurrentTime.self)!.resource.value
        
        self.worldBuffer.resourceBuffer.resource(ofType: DeltaTime.self)?.resource = DeltaTime(value: currentTime - lastTime)
        
        for system in self.worldBuffer.systemBuffer.systems(ofType: UpdateExecute.self) {
            system.update(worldBuffer: self.worldBuffer)
        }
        
        self.applyCommands()
        // apply commands の際に push された entity を chunk に割り振ります.
        self.worldBuffer.chunkBuffer.applyEntityQueue()
        
        self.worldBuffer.resourceBuffer.resource(ofType: CurrentTime.self)?.resource = CurrentTime(value: currentTime)
    }
}
