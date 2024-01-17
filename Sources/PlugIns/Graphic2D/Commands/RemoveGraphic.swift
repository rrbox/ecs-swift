//
//  RemoveGraphic.swift
//  
//
//  Created by rrbox on 2023/08/20.
//

import ECS

class RemoveGraphic: EntityCommand {
    func runCommand(in world: World) {
        world.removeGraphic(fromEntity: self.entity)
    }
}

