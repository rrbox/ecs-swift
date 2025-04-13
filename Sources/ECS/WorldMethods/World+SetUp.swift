//
//  World+SetUp.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public extension World {
    func setUpWorld() {
        let commands = self.worldStorage.commandsStorage.commands()!

        self.applyEnityTransactions(commands: commands)
        self.worldStorage.chunkStorage.applySpawnedEntityQueue()

        // entity の変更を world 全体に適用.
        self.worldStorage.chunkStorage.applyUpdatedEntityQueue()
    }
}
