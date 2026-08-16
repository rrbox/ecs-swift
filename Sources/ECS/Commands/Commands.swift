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
 func spawnBullet(commands: Commands) {
     commands.spawn() // spawn an entity
         .addComponent(Bullet(lifetime: 1))
 }

 func despawnExpiredBullets(
     commands: Commands,
     query: Query2<Entity, Bullet>,
     deltaTime: Resource<DeltaTime>
 ) {
     query.update { entity, bullet in
         bullet.lifetime -= deltaTime.resource.value
         guard bullet.lifetime <= 0 else { return }
         commands.despawn(entity: entity) // despawn the entity
     }
 }
 ```
 */
final public class Commands: SystemParameter {
    var commandQueue = [Command]()
    var generator = EntityGenerator()
    var entityTransactions = [EntityTransaction]()

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
