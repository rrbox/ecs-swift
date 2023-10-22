//
//  EntityRecord.swift
//
//
//  Created by rrbox on 2023/10/22.
//

public enum EntityRecord {}

final public class ComponentRef<T: Component>: Item {
    var value: T
    
    init(value: T) {
        self.value = value
    }
}

final public class EntityRecordRef {
    var map = AnyMap<EntityRecord>()
}

public extension EntityRecordRef {
    func addComponent<T: Component>(_ component: T) {
        self.map.body[ObjectIdentifier(T.self)] = ComponentRef(value: component)
    }
    
    func removeComponent<T: Component>(ofType type: T.Type) {
        self.map.body.removeValue(forKey: ObjectIdentifier(T.self))
    }
    
    func componentRef<T: Component>(_ type: T.Type) -> ComponentRef<T>? {
        guard let result: Item = self.map.body[ObjectIdentifier(T.self)] else { return nil }
        return (result as! ComponentRef<T>)
    }
}
