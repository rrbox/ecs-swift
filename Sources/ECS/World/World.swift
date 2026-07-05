//
//  World.swift
//  
//
//  Created by rrbox on 2023/08/06.
//

/**
 ECS 全体をコントロールします.

 ## Topics

 ### 初期化

 - ``World/init()``

 ### System の追加

 - ``World/addSystem(_:_:)-9frsg``
 - ``World/addSystem(_:_:)-86ff2``
 - ``World/addSystem(_:_:)-7kznt``
 - ``World/addSystem(_:_:)-1s1oy``
 - ``World/addSystem(_:_:)-4jv38``

 ### Event 関連の設定の追加

 - ``World/addEventStreamer(eventType:)``
 - ``World/buildEventResponder(_:_:)``
 - ``World/buildDidSpawnResponder(_:)``
 - ``World/buildWillDespawnResponder(_:)``

 ### 起動

 - ``World/setUpWorld()``

 ### 更新処理

 - ``World/update(currentTime:)``

 ### Event の発信

 - ``World/sendEvent(_:)``

 */
final public class World {
    /// 生存中の全 entity の台帳. 実体は ``WorldStorageRef/entities`` が保持します.
    var entities: SparseSet<EntityRecordRef> {
        get { self.worldStorage.entities }
        set { self.worldStorage.entities = newValue }
    }
    var preUpdateSchedule: Schedule
    var updateSchedule: Schedule
    var postUpdateSchedule: Schedule
    public let worldStorage: WorldStorageRef

    init(worldStorage: WorldStorageRef) {
        self.preUpdateSchedule = .preStartUp
        self.updateSchedule = .startUp
        self.postUpdateSchedule = .postStartUp
        self.worldStorage = worldStorage
    }

}
