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
        // 初期値として設定された state に対して did move schedule で関連づけられた system を実行します.
        for schedule in self.worldStorage.map.valueRef(ofType: StateStorage.StatesDidEnterInStartUp.self)!.body.schedules {
            for system in self.worldStorage.systemStorage.systems(schedule) {
                system.execute(self.worldStorage)
            }
        }
        let commands = self.worldStorage.commandsStorage.commands()!
        
        self.applyEnityTransactions(commands: commands)
        self.worldStorage.chunkStorage.applySpawnedEntityQueue()
        
        self.applyCommands(commands: commands)
        
        // entity の変更を world 全体に適用.
        self.worldStorage.chunkStorage.applyUpdatedEntityQueue()
    }
}
