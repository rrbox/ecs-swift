//
//  EntityRecord.swift
//
//
//  Created by rrbox on 2023/10/22.
//

public enum EntityRecord {}

public class Ref<T>: Item {
    public var value: T {
        get { fatalError("not implemented") }
        set { fatalError("not implemented") }
    }
}

final public class ComponentRef<T: Component>: Ref<T> {
    var _value: T
    
    public override var value: T {
        get { self._value }
        set { self._value = newValue }
    }
    
    init(value: T) {
        self._value = value
    }
}

final public class ImmutableRef<T>: Ref<T> {
    let _value: T
    
    public override var value: T {
        get { self._value }
        set {}
    }
    
    init(value: T) {
        self._value = value
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
    
    func ref<T>(_ type: T.Type) -> Ref<T>? {
        guard let result: Item = self.map.body[ObjectIdentifier(T.self)] else { return nil }
        return (result as! Ref<T>)
    }
    
    func componentRef<T: Component>(ofType type: T.Type) -> ComponentRef<T>? {
        return self.map.body[ObjectIdentifier(T.self)] as? ComponentRef<T>
    }
    
    func component<T: Component>(ofType type: T.Type) -> T? {
        return self.componentRef(ofType: T.self)?.value
    }
}
