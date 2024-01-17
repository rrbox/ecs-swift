//
//  System.swift
//  
//
//  Created by rrbox on 2023/10/24.
//

class System<P: SystemParameter>: SystemExecute {
    let execute: (P) async -> ()
    
   init(_ execute: @escaping (P) async -> ()) {
        self.execute = execute
    }
    
    override func execute(_ worldStorageRef: WorldStorageRef) async {
        await self.execute(P.getParameter(from: worldStorageRef)!)
    }
}

public extension World {
    @discardableResult func addSystem<P: SystemParameter>(_ schedule: Schedule, _ system: @escaping (P) async -> ()) async -> World {
        self.worldStorage.systemStorage.addSystem(schedule, System<P>(system))
        await P.register(to: self.worldStorage)
        return self
    }
}

public extension EventResponderBuilder {
    @discardableResult func addSystem<P: SystemParameter>(_ schedule: Schedule, _ system: @escaping (P) async -> ()) async -> EventResponderBuilder {
        if !self.systems.keys.contains(schedule) {
            self.systems[schedule] = []
        }
        
        self.systems[schedule]!.append(System<P>(system))
        await P.register(to: self.worldStorage)
        return self
    }
}
