//
//  World+Spawn.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

extension World {
    /// Entity を登録します.
    ///
    /// ``Commands/spawn()`` が実行された後, フレームが終了するタイミングでこの関数が実行されます.
    /// entity へのコンポーネントの登録などは, spawn の後に行われます.
    func spawn(entity: Entity, value: Archetype) {
        self.entities[entity] = value
        self.worldBuffer
            .chunkBuffer
            .spawn(entity: entity, value: value)
    }
    
    /// Entity を削除します.
    ///
    /// ``Commands/despawn()`` が実行された後, フレームが終了するタイミングでこの関数が実行されます.
    func despawn(entity: Entity) {
        self.entities.removeValue(forKey: entity)
        self.worldBuffer
            .chunkBuffer
            .despawn(entity: entity)
    }
}
