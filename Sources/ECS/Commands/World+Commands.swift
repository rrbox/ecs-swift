//
//  World+Commands.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension World {
    func applyCommands() {
        let commands = self.worldBuffer.commandsStorage.commands()!
        for command in commands.commandQueue {
            command.runCommand(in: self)
        }
        commands.commandQueue = []
    }
}
