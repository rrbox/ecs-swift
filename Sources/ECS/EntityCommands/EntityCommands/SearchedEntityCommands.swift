//
//  SearchedEntityCommands.swift
//
//
//  Created by rrbox on 2024/02/18.
//

final public class SearchedEntityCommands: EntityCommands {
    init(entity: Entity, commandsQueue: SearchedEntityCommandQueue) {
        super.init(entity: entity, commandsQueue: commandsQueue)
    }
}
