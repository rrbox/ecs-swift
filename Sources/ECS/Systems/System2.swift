//
//  System2.swift
//  
//
//  Created by rrbox on 2023/10/24.
//

class System2<P0: SystemParameter, P1: SystemParameter>: SystemExecute {
    let execute: (P0, P1) async -> ()
    
   init(_ execute: @escaping (P0, P1) async -> ()) {
        self.execute = execute
    }
    
    override func execute(_ worldStorageRef: WorldStorageRef) async {
        await self.execute(P0.getParameter(from: worldStorageRef)!, P1.getParameter(from: worldStorageRef)!)
    }
}

public extension World {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter>(_ schedule: Schedule, _ system: @escaping (P0, P1) async -> ()) async -> World {
        self.worldStorage.systemStorage.addSystem(schedule, System2<P0, P1>(system))
        await P0.register(to: self.worldStorage)
        await P1.register(to: self.worldStorage)
        return self
    }
}

public extension EventResponderBuilder {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter>(_ schedule: Schedule, _ system: @escaping (P0, P1) async -> ()) async -> EventResponderBuilder {
        if !self.systems.keys.contains(schedule) {
            self.systems[schedule] = []
        }
        
        self.systems[schedule]?.append(System2<P0, P1>(system))
        await P0.register(to: self.worldStorage)
        await P1.register(to: self.worldStorage)
        return self
    }
}

