//
//  CommandsBuffer.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

import Foundation

class CommandsBuffer {
    class CommandsRegistry: BufferElement {
        let commands: Commands
        init(commands: Commands) {
            self.commands = commands
            super.init()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    let buffer: Buffer
    
    init(buffer: Buffer) {
        self.buffer = buffer
    }
    
    func commands() -> Commands? {
        self.buffer.component(ofType: CommandsRegistry.self)?.commands
    }
    
    func setCommands(_ commands: Commands) {
        self.buffer.addComponent(CommandsRegistry(commands: commands))
    }
}

// WorldBuffer + Commands
extension WorldBuffer {
    var commandsBuffer: CommandsBuffer {
        CommandsBuffer(buffer: self)
    }
}
