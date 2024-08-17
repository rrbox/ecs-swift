//
//  World+Graphic2D.swift
//  
//
//  Created by rrbox on 2023/08/20.
//

import GameplayKit
import ECS

extension World {
    func removeGraphic(fromEntity entity: Entity) {
        let entityRecord = self.entityRecord(forEntity: entity)!
        entityRecord.removeComponent(ofType: GraphicStrongRef.self)
    }
}
