//
//  World+Commands.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension World {
    func applyCommands() {
        let commands = self.worldStorage.commandsStorage.commands()!
        for transaction in commands.entityTransactions {
            transaction.runCommand(in: self)
        }
        for command in commands.commandQueue {
            command.runCommand(in: self)
        }
        commands.entityTransactions = []
        commands.commandQueue = []
    }
}
