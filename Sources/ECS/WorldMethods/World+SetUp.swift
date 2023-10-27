//
//  World+SetUp.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public extension World {
    func setUpWorld() {
        for system in self.worldStorage.systemStorage.systems(ofType: SetUpExecute.self) {
            system.setUp(worldStorage: self.worldStorage)
        }
        self.applyCommands()
        self.worldStorage.chunkStorage.applyEntityQueue()
    }
}
