//
//  DespawnCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class DespawnCommand: EntityTransaction {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    override func runCommand(in world: World) {
        guard world.entities.contains(self.entity) else { return }

        world.worldStorage.commands.recycleSlot(of: self.entity)
        world.despawn(entity: self.entity)
    }
}
