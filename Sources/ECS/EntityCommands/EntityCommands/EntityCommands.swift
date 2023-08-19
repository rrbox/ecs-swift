//
//  EntityCommands.swift
//  
//
//  Created by rrbox on 2023/08/09.
//

final public class EntityCommands {
    let entity: Entity
    let commands: Commands
    
    init(entity: Entity, commands: Commands) {
        self.entity = entity
        self.commands = commands
    }
    
    public func pushCommand(_ command: Command) {
        self.commands.commandQueue.append(command)
    }
    
    /// Commands で操作した Entity を受け取ります.
    /// - Returns: ID としての Entity をそのまま返します.
    public func id() -> Entity {
        self.entity
    }
    
    /// Entity に Component を追加します.
    /// - Parameter component: 追加するコンポーネントを指定します.
    /// - Returns: Entity component のビルダーです.
    @discardableResult public func addComponent<ComponentType: Component>(_ component: ComponentType) -> EntityCommands {
        self.commands.commandQueue.append(AddComponent(entity: self.entity, componnet: component))
        return self
    }
    
    /// Entity から Component を削除します.
    /// - Parameter type: 削除する Component の型を指定します.
    /// - Returns: Entity component のビルダーです.
    @discardableResult public func removeComponent<ComponentType: Component>(ofType type: ComponentType.Type) -> EntityCommands {
        self.commands.commandQueue.append(RemoveComponent(entity: self.entity, componentType: ComponentType.self))
        return self
    }
    
}
