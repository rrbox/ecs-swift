//
//  EntityCommands.swift
//
//
//  Created by rrbox on 2023/08/09.
//

/// `EntityCommands` の公開メソッドから呼ばれる enqueue フックです。
///
/// 公開 API(`addComponent` / `removeComponent(ofType:)` / `addBundle` /
/// `pushCommand`)を変えずに蓄積先を差し替えるための内部境界です(要件 3-2)。
/// 旧経路(`EntityCommandQueue`)は現行どおり `EntityCommand` を積み、
/// 新経路(`SearchedEntityDiffQueue`)は `ComponentDiff` を積みます。
protocol EntityCommandsQueue: AnyObject {
    /// コンポーネント追加の enqueue フックです。
    func enqueue<C: Component>(componentToAdd component: C, forEntity entity: Entity)

    /// コンポーネント削除の enqueue フックです。
    func enqueue<C: Component>(componentTypeToRemove type: C.Type, forEntity entity: Entity)

    /// bundle 追加の enqueue フックです。
    func enqueue<B: BundleProtocol>(bundleToAdd bundle: B, forEntity entity: Entity)

    /// カスタム `EntityCommand` の enqueue フックです。
    func enqueue(customCommand command: EntityCommand)
}

class EntityCommandQueue: EntityTransaction {
    var queue = [EntityCommand]()
}

extension EntityCommandQueue: EntityCommandsQueue {
    // 旧経路のフック実装: 現行どおり EntityCommand を生成して積みます(挙動不変)。

    func enqueue<C: Component>(componentToAdd component: C, forEntity entity: Entity) {
        self.queue.append(AddComponent(entity: entity, component: component))
    }

    func enqueue<C: Component>(componentTypeToRemove type: C.Type, forEntity entity: Entity) {
        self.queue.append(RemoveComponent(entity: entity, componentType: C.self))
    }

    func enqueue<B: BundleProtocol>(bundleToAdd bundle: B, forEntity entity: Entity) {
        self.queue.append(AddBundle(entity: entity, bundle: bundle))
    }

    func enqueue(customCommand command: EntityCommand) {
        self.queue.append(command)
    }
}

final class SpawnedEntityCommandQueue: EntityCommandQueue {
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

final class SearchedEntityCommandQueue: EntityCommandQueue {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    override func runCommand(in world: World) {
        guard let record = world.entityRecord(forEntity: self.entity) else { return }
        world.worldStorage.chunkStorageRef.pushUpdated(entityRecord: record)
        self.queue.forEach { command in
            command.runCommand(forRecord: record, inWorld: world)
        }
    }
}

extension SearchedEntityDiffQueue: EntityCommandsQueue {
    // 新経路のフック実装: EntityCommand の代わりに ComponentDiff を積みます(要件 3-3)。
    // 対象 entity は自身が保持しているため、フックの entity 引数は使用しません。

    func enqueue<C: Component>(componentToAdd component: C, forEntity entity: Entity) {
        self.diffs.append(.add(ComponentRef(value: component)))
    }

    func enqueue<C: Component>(componentTypeToRemove type: C.Type, forEntity entity: Entity) {
        self.diffs.append(.remove(ObjectIdentifier(C.self)))
    }

    func enqueue<B: BundleProtocol>(bundleToAdd bundle: B, forEntity entity: Entity) {
        // 一時的な空 record に bundle を展開し、エントリを add 差分へ変換します
        // (`@Bundle` 互換を searched 経路でも維持します)。
        let record = EntityRecordRef(entity: entity)
        bundle.addComponent(forEntity: record)
        for insertable in record.archetypeInsertables() {
            self.diffs.append(.add(insertable))
        }
    }

    func enqueue(customCommand command: EntityCommand) {
        // カスタム EntityCommand は record を前提とするため、archetype storage ON の
        // searched 経路では未サポートです(design.md エラーハンドリング)。
        assertionFailure("Custom EntityCommand is not supported on searched entities with archetype storage.")
    }
}

public class EntityCommands {
    let entity: Entity
    let commandQueue: EntityCommandsQueue

    init(entity: Entity, commandsQueue: EntityCommandsQueue) {
        self.entity = entity
        self.commandQueue = commandsQueue
    }

    public func pushCommand(_ command: EntityCommand) {
        self.commandQueue.enqueue(customCommand: command)
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
        self.commandQueue.enqueue(componentToAdd: component, forEntity: self.entity)
        return self
    }

    /// Entity から Component を削除します.
    /// - Parameter type: 削除する Component の型を指定します.
    /// - Returns: Entity component のビルダーです.
    @discardableResult public func removeComponent<ComponentType: Component>(ofType type: ComponentType.Type) -> Self {
        self.commandQueue.enqueue(componentTypeToRemove: ComponentType.self, forEntity: self.entity)
        return self
    }

    @discardableResult public func addBundle<T: BundleProtocol>(_ bundle: T) -> Self {
        self.commandQueue.enqueue(bundleToAdd: bundle, forEntity: self.entity)
        return self
    }

}
