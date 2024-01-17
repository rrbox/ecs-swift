//
//  DespawnCommand.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

class DespawnCommand: EntityCommand {
    override func runCommand(in world: World) async {
        await world.despawn(entity: self.entity)
    }
}
