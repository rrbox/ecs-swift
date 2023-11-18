//
//  World+SetUp.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public extension World {
    func setUpWorld() {
        for system in self.worldStorage.systemStorage.systems(.startUp) {
            system.execute(self.worldStorage)
        }
        self.applyCommands()
        self.worldStorage.chunkStorage.applyEntityQueue()
    }
}
