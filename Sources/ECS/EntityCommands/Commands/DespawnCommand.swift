//
//  DespawnCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class DespawnCommand: Command {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    override func runCommand(in world: World) {
        world.despawn(entity: self.entity)
    }
}
