//
//  World+Commands.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension World {
    func applyEnityTransactions(commands: Commands) {
        for transaction in commands.entityTransactions {
            transaction.runCommand(in: self)
        }
        commands.entityTransactions = []
    }
    
    func applyCommands(commands: Commands) {
        for command in commands.commandQueue {
            command.runCommand(in: self)
        }
        commands.commandQueue = []
    }
}
