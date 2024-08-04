//
//  SpawnedEntityCommands.swift
//  
//
//  Created by rrbox on 2024/02/18.
//

final public class SpawnedEntityCommands: EntityCommands {
    init(entity: Entity, commandsQueue: SpawnedEntityCommandQueue) {
        super.init(entity: entity, commandsQueue: commandsQueue)
    }
}
