//
//  System.swift
//  
//
//  Created by rrbox on 2023/10/24.
//

class System<P: SystemParameter>: SystemExecute {
    let execute: (P) -> ()

    init(_ execute: @escaping (P) -> ()) {
        self.execute = execute
    }

    override func execute(_ worldStorageRef: WorldStorageRef) {
        self.execute(P.getParameter(from: worldStorageRef)!)
    }
}

public extension World {
    @discardableResult func addSystem<P: SystemParameter>(_ schedule: Schedule, _ system: @escaping (P) -> ()) -> World {
        self.worldStorage.systemStorage.addSystem(schedule, System<P>(system))
        P.register(to: self.worldStorage)
        return self
    }
}

public extension EventResponderBuilder {
    @discardableResult func addSystem<P: SystemParameter>(_ schedule: Schedule, _ system: @escaping (P) -> ()) -> EventResponderBuilder {
        if !self.systems.keys.contains(schedule) {
            self.systems[schedule] = []
        }

        self.systems[schedule]!.append(System<P>(system))
        P.register(to: self.worldStorage)
        return self
    }
}
