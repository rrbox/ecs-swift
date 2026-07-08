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
    var generator = EntityGenerator()
    var entityTransactions = [EntityTransaction]()

    /// この Commands を保持する `WorldStorageRef` への逆参照です。
    ///
    /// `entity(_)` が archetype storage の ON/OFF(`experimentalOptions`)を参照して
    /// queue 実装を選択するために使用します(design.md World 分岐点)。
    /// `WorldStorageRef` が Commands を強参照するため、循環を避けて weak で保持します。
    /// `WorldStorageRef.init` で設定されます。
    weak var worldStorage: WorldStorageRef?

    /// Commands では, World への登録時には何もしません.
    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> Commands? {
        worldStorage.commands
    }

    /// CommandQueue にコマンドを追加します.
    public func push(command: Command) {
        self.commandQueue.append(command)
    }
}

// MARK: - life cycle

extension Commands {
    func refreshEntityTransactions() {
        entityTransactions = []
    }

    func refreshCommandQueue() {
        commandQueue = []
    }
}
