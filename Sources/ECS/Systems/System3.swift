//
//  System3.swift
//  
//
//  Created by rrbox on 2023/10/24.
//

class System3<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>: SystemExecute {
    let execute: (P0, P1, P2) async -> ()
    
    init(_ execute: @escaping (P0, P1, P2) async -> ()) {
        self.execute = execute
    }
    
    override func execute(_ worlfBuffer: WorldStorageRef) async {
        await self.execute(P0.getParameter(from: worlfBuffer)!,
                           P1.getParameter(from: worlfBuffer)!,
                           P2.getParameter(from: worlfBuffer)!)
    }
}

public extension World {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>(
        _ schedule: Schedule,
        _ system: @escaping (P0, P1, P2) async -> ()
    ) async -> World {
        self.worldStorage.systemStorage.addSystem(schedule, System3(system))
        await P0.register(to: self.worldStorage)
        await P1.register(to: self.worldStorage)
        await P2.register(to: self.worldStorage)
        return self
    }
}

public extension EventResponderBuilder {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>(
        _ schedule: Schedule,
        _ system: @escaping (P0, P1, P2) async -> ()
    ) async -> EventResponderBuilder {
        if !self.systems.keys.contains(schedule) {
            self.systems[schedule] = []
        }
        
        self.systems[schedule]?.append(System3<P0, P1, P2>(system))
        await P0.register(to: self.worldStorage)
        await P1.register(to: self.worldStorage)
        await P2.register(to: self.worldStorage)
        return self
    }
}
