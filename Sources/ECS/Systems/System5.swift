//
//  System5.swift
//  
//
//  Created by rrbox on 2023/10/24.
//

class System5<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>: SystemExecute {
    let execute: (P0, P1, P2, P3, P4) async -> ()
    
    init(_ execute: @escaping (P0, P1, P2, P3, P4) async -> ()) {
        self.execute = execute
    }
    
    override func execute(_ worldStorageRef: WorldStorageRef) async {
        await self.execute(P0.getParameter(from: worldStorageRef)!,
                           P1.getParameter(from: worldStorageRef)!,
                           P2.getParameter(from: worldStorageRef)!,
                           P3.getParameter(from: worldStorageRef)!,
                           P4.getParameter(from: worldStorageRef)!)
    }
}

public extension World {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>(
        _ schedule: Schedule,
        _ system: @escaping (P0, P1, P2, P3, P4) async -> ()
    ) async -> World {
        self.worldStorage.systemStorage.addSystem(schedule, System5<P0, P1, P2, P3, P4>(system))
        await P0.register(to: self.worldStorage)
        await P1.register(to: self.worldStorage)
        await P2.register(to: self.worldStorage)
        await P3.register(to: self.worldStorage)
        await P4.register(to: self.worldStorage)
        return self
    }
}

public extension EventResponderBuilder {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>(
        _ schedule: Schedule,
        _ system: @escaping (P0, P1, P2, P3, P4) async -> ()
    ) async -> EventResponderBuilder {
        if !self.systems.keys.contains(schedule) {
            self.systems[schedule] = []
        }
        
        self.systems[schedule]?.append(System5<P0, P1, P2, P3, P4>(system))
        await P0.register(to: self.worldStorage)
        await P1.register(to: self.worldStorage)
        await P2.register(to: self.worldStorage)
        await P3.register(to: self.worldStorage)
        await P4.register(to: self.worldStorage)
        return self
    }
}
