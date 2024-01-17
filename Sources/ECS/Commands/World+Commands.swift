//
//  World+Commands.swift
//  
//
//  Created by rrbox on 2023/08/11.
//

extension World {
    func applyCommands() async {
        let commands = self.worldStorage.commandsStorage.commands()!
        for command in await commands.commandQueue {
            await command.runCommand(in: self)
        }
        await commands.clearAllCommand()
    }
}
