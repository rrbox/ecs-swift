//
//  World+SetUp.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public extension World {
    func setUpWorld() {
        for system in self.worldBuffer.systemStorage.systems(ofType: SetUpExecute.self) {
            system.setUp(worldBuffer: self.worldBuffer)
        }
        self.applyCommands()
        self.worldBuffer.chunkStorage.applyEntityQueue()
    }
}
