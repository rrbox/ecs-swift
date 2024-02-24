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
 - ``World/buildWillSpawnResponder(_:)``
 
 ### 起動
 
 - ``World/setUpWorld()``
 
 ### 更新処理
 
 - ``World/update(currentTime:)``
 
 ### Event の発信
 
 - ``World/sendEvent(_:)``
 
 */
final public class World {
    var entities: SparseSet<EntityRecordRef>
    var updateSchedule: Schedule
    public let worldStorage: WorldStorageRef
    
    init(worldStorage: WorldStorageRef) {
        self.entities = SparseSet(sparse: [], dense: [], data: [])
        self.updateSchedule = .firstFrame
        self.worldStorage = worldStorage
    }
    
}
