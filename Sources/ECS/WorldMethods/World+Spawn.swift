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
    /// entity へのコンポーネントの登録などは, push の後に行われます.
    func push(entity: Entity, entityRecord: EntityRecord) {
        self.entities.insert(entity: entity, entityRecord: entityRecord)
        self.worldBuffer
            .chunkBuffer
            .push(entity: entity, entityRecord: entityRecord)
    }
    
    /// Entity を削除します.
    ///
    /// ``Commands/despawn()`` が実行された後, フレームが終了するタイミングでこの関数が実行されます.
    func despawn(entity: Entity) {
        self.entities.remove(entity: entity)
        self.worldBuffer
            .chunkBuffer
            .despawn(entity: entity)
    }
}
