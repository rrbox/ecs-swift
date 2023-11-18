//
//  Commands.swift
//  
//
//  Created by rrbox on 2023/08/09.
//

final public class Commands: SystemParameter {
    var commandQueue = [Command]()
    
    /// Commands では, World への登録時には何もしません.
    public static func register(to worldStorage: WorldStorageRef) {
        
    }
    
    public static func getParameter(from worldStorage: WorldStorageRef) -> Commands? {
        worldStorage.commandsStorage.commands()
    }
    
    /// CommandQueue にコマンドを追加します.
    public func push(command: Command) {
        self.commandQueue.append(command)
    }
}
