//
//  Commands.swift
//  
//
//  Created by rrbox on 2023/08/09.
//

/// ``World`` 内の ``Entity`` のようなリソースを生成・削除します.
///
/// ## Overview
///
/// Commands はシステムから ``World`` 内のデータを操作します.
/**
 ```swift
 func system(commands: Commands) {
     let entity = commands.spawn() // spawn an entity
         .addComponent(ComponentType())
         .id()
     commands.despawn(entity) // despawn the entity
 }
 ```
 */
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
