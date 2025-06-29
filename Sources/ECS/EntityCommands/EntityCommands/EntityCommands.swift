//
//  EntityCommands.swift
//  
//
//  Created by rrbox on 2023/08/09.
//

class EntityCommandQueue: EntityTransaction {
    var queue = [EntityCommand]()
}

class SpawnedEntityCommandQueue: EntityCommandQueue {
    let record: EntityRecordRef

    init(record: EntityRecordRef) {
        self.record = record
    }

    override func runCommand(in world: World) {
        self.queue.forEach { command in
            command.runCommand(forRecord: self.record, inWorld: world)
        }
    }
}

class SearchedEntityCommandQueue: EntityCommandQueue {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    override func runCommand(in world: World) {
        guard let record = world.entityRecord(forEntity: self.entity) else { return }
        world.worldStorage.chunkStorage.pushUpdated(entityRecord: record)
        self.queue.forEach { command in
            command.runCommand(forRecord: record, inWorld: world)
        }
    }
}

public class EntityCommands {
    let entity: Entity
    let commandQueue: EntityCommandQueue

    init(entity: Entity, commandsQueue: EntityCommandQueue) {
        self.entity = entity
        self.commandQueue = commandsQueue
    }

    public func pushCommand(_ command: EntityCommand) {
        self.commandQueue.queue.append(command)
    }

    /// Commands で操作した Entity を受け取ります.
    /// - Returns: ID としての Entity をそのまま返します.
    public func id() -> Entity {
        self.entity
    }

    /// Entity に Component を追加します.
    /// - Parameter component: 追加するコンポーネントを指定します.
    /// - Returns: Entity component のビルダーです.
    @discardableResult public func addComponent<ComponentType: Component>(_ component: ComponentType) -> Self {
        self.pushCommand(AddComponent(entity: self.entity, component: component))
        return self
    }

    /// Entity から Component を削除します.
    /// - Parameter type: 削除する Component の型を指定します.
    /// - Returns: Entity component のビルダーです.
    @discardableResult public func removeComponent<ComponentType: Component>(ofType type: ComponentType.Type) -> Self {
        self.pushCommand(RemoveComponent(entity: entity, componentType: ComponentType.self))
        return self
    }

    @discardableResult public func addBundle<T: BundleProtocol>(_ bundle: T) -> Self {
        self.pushCommand(AddBundle(entity: self.entity, bundle: bundle))
        return self
    }

}
