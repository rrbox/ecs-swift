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
        let currentTimeResource = worldStorage.resourceStorage.resource(ofType: CurrentTime.self)!

        worldStorage.resourceStorage.resource(ofType: DeltaTime.self)?.resource = DeltaTime(value: currentTime - currentTimeResource.resource.value)

        currentTimeResource.resource = CurrentTime(value: currentTime)

        let commands = worldStorage.commands

        // lifecycle 1: pre update
        self.preUpdatePhase()
        self.applyCommandsPhase(commands)

        // lifecycle 2: udpate
        self.updatePhase()
        self.applyCommandsPhase(commands)

        // lifecycle 3: post update
        self.postUpdatePhase()
        self.applyCommandsPhase(commands)
    }
}

extension World {
    func preUpdatePhase() {
        let systemStorage = worldStorage.systemStorage
        let stateStorage = worldStorage.stateStorage
        let stateSchedulesManager = worldStorage
            .stateStorage
            .valueRef(ofType: StateAssociatedSchedules.self)!
            .body

        let willExitQueue = stateStorage.willExitQueue()
        let didEnterQueue = stateStorage.didEnterQueue()
        let onPauseQueue = stateStorage.onPauseQueue()
        let onResumeQueue = stateStorage.onResumeQueue()

        let onUpdatePreviousStateQueue = stateStorage.onUpdatePreviousStateQueue()
        let onUpdateNewStateQueue = stateStorage.onUpdateNewStateQueue()
        let onStackUpdatePreviousStateQueue = stateStorage.onStackUpdatePreviousStateQueue()
        let onStackUpdateNewStateQueue = stateStorage.onStackUpdateNewStateQueue()
        let onInactiveUpdatePreviousStateQueue = stateStorage.onInactivePreviousStateQueue()
        let onInactiveUpdateNewStateQueue = stateStorage.onInactiveNewStateQueue()
        let removedOnNewStateQueue = stateStorage.removedOnNewStateQueue()
        let removedOnPreviousStateQueue = stateStorage.removedOnPreviousStateQueue()
        let removedOnStackNewStateQueue = stateStorage.removedOnStackNewStateQueue()
        let removedOnStackPreviousStateQueue = stateStorage.removedOnStackPreviousStateQueue()
        let removedOnInactiveNewStateQueue = stateStorage.removedOnInactiveNewStateQueue()
        let removedOnInactivePreviousStateQueue = stateStorage.removedOnInactivePreviousStateQueue()

        stateStorage.clearQueue()

        for system in systemStorage.systems(self.preUpdateSchedule) {
            system.execute(worldStorage)
        }

        // state が queue に入っていたら will exit と did enter を呼び出す
        // queue を for-loop して state を取り出す

        for previousState in onUpdatePreviousStateQueue {
            stateSchedulesManager.schedules.remove(previousState)
        }
        
        for previousState in onStackUpdatePreviousStateQueue {
            stateSchedulesManager.schedules.remove(previousState)
        }

        for previousState in onInactiveUpdatePreviousStateQueue {
            stateSchedulesManager.schedules.remove(previousState)
        }

        for previousState in removedOnPreviousStateQueue {
            stateSchedulesManager.removedSchedules.remove(previousState)
        }

        for previousState in removedOnStackPreviousStateQueue {
            stateSchedulesManager.removedSchedules.remove(previousState)
        }

        for previousState in removedOnInactivePreviousStateQueue {
            stateSchedulesManager.removedSchedules.remove(previousState)
        }

        for willExit in willExitQueue {
            for system in systemStorage.systems(willExit) {
                system.execute(worldStorage)
            }
        }

        for onPause in onPauseQueue {
            for system in systemStorage.systems(onPause) {
                system.execute(worldStorage)
            }
        }

        for onResume in onResumeQueue {
            for system in systemStorage.systems(onResume) {
                system.execute(worldStorage)
            }
        }

        for didEnter in didEnterQueue {
            for system in systemStorage.systems(didEnter) {
                system.execute(worldStorage)
            }
        }

        for newState in onUpdateNewStateQueue {
            stateSchedulesManager.schedules.insert(newState)
        }

        for newState in onStackUpdateNewStateQueue {
            stateSchedulesManager.schedules.insert(newState)
        }

        for newState in onInactiveUpdateNewStateQueue {
            stateSchedulesManager.schedules.insert(newState)
        }

        for newState in removedOnNewStateQueue {
            stateSchedulesManager.removedSchedules.insert(newState)
        }

        for newState in removedOnStackNewStateQueue {
            stateSchedulesManager.removedSchedules.insert(newState)
        }

        for newState in removedOnInactiveNewStateQueue {
            stateSchedulesManager.removedSchedules.insert(newState)
        }

        self.applyEventQueue()
    }

    func updatePhase() {
        let systemStorage = worldStorage.systemStorage
        let stateStorage = worldStorage.stateStorage

        for system in systemStorage.systems(self.updateSchedule) {
            system.execute(self.worldStorage)
        }

        // activate な state を shcedule によって紐づけられた system を実行します.
        for schedule in stateStorage.currentSchedulesWhichAssociatedStates() {
            for system in self.worldStorage.systemStorage.systems(schedule) {
                system.execute(self.worldStorage)
            }
        }

        // world が受信した event を event system に発信します.
        self.applyEventQueue()
    }

    func postUpdatePhase() {
        for system in self.worldStorage.systemStorage.systems(self.postUpdateSchedule) {
            system.execute(self.worldStorage)
        }

        self.applyEventQueue()
    }

    // 各システムが動いた後に実行される
    //
    // archetype storage の ON/OFF で spawn/updated queue の適用先が分岐します
    // (design.md World 分岐点4)。適用順序(spawn 適用 → commands → updated/diff 適用)は
    // 新旧共通で現行を踏襲します(要件 1-5)。
    func applyCommandsPhase(_ commands: Commands) {
        // removed event を配信します.
        self.applyRemovedEventQueue()

        // これから spawn する entity を storage 内で enqueue
        // despawn 登録された entity を削除
        // これから spawn する record に addComponent などのコマンドを実行
        // (ON: staging record への適用 / OFF: セットアップされた record を chunk storage 内で enqueue)
        self.applyEnityTransactions(commands: commands)

        if let archetypeStorage = self.worldStorage.archetypeStorageRef {
            // ON: staging record を Archetype へ挿入し, entityIndex に所在を登録します(spawn 適用).
            // record へのコマンド適用は直前の applyEnityTransactions で完了しているため,
            // 挿入時点で spawn コマンドのコンポーネントはすべて揃っています.
            archetypeStorage.applySpawnStaging()

            self.applyCommands(commands: commands)

            // searched entity への変更差分を Archetype 移動として適用します(updated/diff 適用).
            // OFF 経路の applyUpdatedEntityQueue と同じ位置(commands の後)で実行することで
            // 適用順序を現行踏襲とします(要件 1-5).
            archetypeStorage.applyDiffQueues()
        } else {
            // apply commands の際に push された entity を chunk に割り振ります(spawn).
            self.worldStorage.chunkStorageRef.applySpawnedEntityQueue()

            self.applyCommands(commands: commands)

            // world 内の entity のコンポーネントの追加/削除.
            // 同じフレーム内で entity の変更を world 全体に適用するために一番最後に再度実行.
            self.worldStorage.chunkStorageRef.applyUpdatedEntityQueue()
        }
    }
}
