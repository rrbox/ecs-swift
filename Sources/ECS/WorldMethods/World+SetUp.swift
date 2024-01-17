//
//  World+SetUp.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public extension World {
    @MainActor
    func setUpWorld() async {
        for system in self.worldStorage.systemStorage.systems(.startUp) {
            await system.execute(self.worldStorage)
        }
        // 初期値として設定された state に対して did move schedule で関連づけられた system を実行します.
        for schedule in self.worldStorage.map.valueRef(ofType: StateStorage.StatesDidEnterInStartUp.self)!.body.schedules {
            for system in self.worldStorage.systemStorage.systems(schedule) {
                await system.execute(self.worldStorage)
            }
        }
        await self.applyCommands()
        await self.worldStorage.chunkStorage.applyEntityQueue()
    }
}
