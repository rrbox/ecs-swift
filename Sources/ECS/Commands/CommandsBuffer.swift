//
//  CommandsBuffer.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

final public class CommandsBuffer {
    class CommandsRegistry: BufferElement {
        let commands: Commands
        
        init(commands: Commands) {
            self.commands = commands
        }
    }
    let buffer: BufferRef
    
    init(buffer: BufferRef) {
        self.buffer = buffer
    }
    
    public func commands() -> Commands? {
        self.buffer.map.valueRef(ofType: CommandsRegistry.self)?.body.commands
    }
    
    func setCommands(_ commands: Commands) {
        self.buffer.map.push(CommandsRegistry(commands: commands))
    }
}

// WorldBuffer + Commands
public extension BufferRef {
    var commandsBuffer: CommandsBuffer {
        CommandsBuffer(buffer: self)
    }
}
