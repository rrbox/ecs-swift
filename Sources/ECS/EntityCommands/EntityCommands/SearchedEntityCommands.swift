//
//  SearchedEntityCommands.swift
//
//
//  Created by rrbox on 2024/02/18.
//


final public class SearchedEntityCommands: EntityCommands {
    /// Entity に Component を追加します.
    /// - Parameter component: 追加するコンポーネントを指定します.
    /// - Returns: Entity component のビルダーです.
    @discardableResult public override func addComponent<ComponentType: Component>(_ component: ComponentType) -> EntityCommands {
        self.commands.componentTramsactions.append(AddComponent(entity: self.entity, component: component))
        return self
    }
    
    /// Entity から Component を削除します.
    /// - Parameter type: 削除する Component の型を指定します.
    /// - Returns: Entity component のビルダーです.
    @discardableResult public override func removeComponent<ComponentType: Component>(ofType type: ComponentType.Type) -> EntityCommands {
        self.commands.componentTramsactions.append(RemoveComponent(entity: self.entity, componentType: ComponentType.self))
        return self
    }
}

