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
    /**
     ゲームの更新処理を実行します.
     
     - note: 最初のフレーム (current time = 0) は準備用フレームとして実行されるため, システムが実行されません.
     */
    func update(currentTime: TimeInterval) {
        let currentTimeResource = self.worldStorage.resourceBuffer.resource(ofType: CurrentTime.self)!
        
        self.worldStorage.resourceBuffer.resource(ofType: DeltaTime.self)?.resource = DeltaTime(value: currentTime - currentTimeResource.resource.value)
        
        currentTimeResource.resource = CurrentTime(value: currentTime)
        
        for system in self.worldStorage.systemStorage.systems(self.updateSchedule) {
            system.execute(self.worldStorage)
        }
        
        // activate な state を shcedule によって紐づけられた system を実行します.
        for schedule in self.worldStorage.stateStorage.currentSchedulesWhichAssociatedStates() {
            for system in self.worldStorage.systemStorage.systems(schedule) {
                system.execute(self.worldStorage)
            }
        }
        
        // world が受信した event を event system に発信します.
        self.applyEventQueue()
        
        let commands = self.worldStorage.commandsStorage.commands()!
        
        // will despawn event を配信します.
        self.applyCommandsEventQueue(eventOfType: WillDespawnEvent.self)
        
        // これから spawn する entity を chunk storage 内で enqueue
        // despawn 登録された entity を削除
        // これから spawn する record に addComponent などのコマンドを実行
        // セットアップされた record を chunk storage 内で enqueue
        self.applyEnityTransactions(commands: commands)
        
        // apply commands の際に push された entity を chunk に割り振ります(spawn).
        self.worldStorage.chunkStorage.applySpawnedEntityQueue()
        
        // Did Spawn event を event system に発信します.
        self.applyCommandsEventQueue(eventOfType: DidSpawnEvent.self)
        
        self.applyCommands(commands: commands)
        
        // world 内の entity のコンポーネントの追加/削除.
        // 同じフレーム内で entity の変更を world 全体に適用するために一番最後に再度実行.
        self.worldStorage.chunkStorage.applyUpdatedEntityQueue()
    }
}
