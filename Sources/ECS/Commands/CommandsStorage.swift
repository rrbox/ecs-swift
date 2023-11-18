//
//  CommandsStorage.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

final public class CommandsStorage {
    class CommandsRegistry: WorldStorageElement {
        let commands: Commands
        
        init(commands: Commands) {
            self.commands = commands
        }
    }
    let buffer: WorldStorageRef
    
    init(buffer: WorldStorageRef) {
        self.buffer = buffer
    }
    
    public func commands() -> Commands? {
        self.buffer.map.valueRef(ofType: CommandsRegistry.self)?.body.commands
    }
    
    func setCommands(_ commands: Commands) {
        self.buffer.map.push(CommandsRegistry(commands: commands))
    }
}

// WorldStorage + Commands
public extension WorldStorageRef {
    var commandsStorage: CommandsStorage {
        CommandsStorage(buffer: self)
    }
}
