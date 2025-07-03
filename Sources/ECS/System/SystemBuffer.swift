//
//  SystemStorage.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

enum SystemStorage: WorldStorageType {}

protocol SystemStorageElement: WorldStorageElement {}

public class SystemExecute {
    init() {}
    public func execute(_ worldStorage: WorldStorageRef) {}
}

final class SystemRegistry: SystemStorageElement {
    var systems = [Schedule: [SystemExecute]]()
}

extension AnyMap where Mode == SystemStorage {
    mutating func push<T: SystemStorageElement>(_ data: T) {
        self.body[ObjectIdentifier(T.self)] = Box(body: data)
    }

    mutating func pop<T: SystemStorageElement>(_ type: T.Type) {
        self.body.removeValue(forKey: ObjectIdentifier(T.self))
    }

    func valueRef<T: SystemStorageElement>(ofType type: T.Type) -> Box<T>? {
        guard let result = self.body[ObjectIdentifier(T.self)] else { return nil }
        return (result as! Box<T>)
    }
}


extension AnyMap<SystemStorage> {

    public func systems(_ schedule: Schedule) -> [SystemExecute] {
        valueRef(ofType: SystemRegistry.self)!.body.systems[schedule]!
    }

    mutating func registerSystemRegistry() {
        push(SystemRegistry.init())
    }

    func insertSchedule(_ schedule: Schedule) {
        valueRef(ofType: SystemRegistry.self)!.body.systems[schedule] = []
    }

    func addSystem(_ schedule: Schedule, _ system: SystemExecute) {
        valueRef(ofType: SystemRegistry.self)!
            .body
            .systems[schedule]!
            .append(system)
    }
}

public extension World {
    @discardableResult func insertSchedule(_ schedule: Schedule) -> World {
        self.worldStorage.systemStorage.insertSchedule(schedule)
        return self
    }
}
