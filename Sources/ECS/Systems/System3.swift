//
//  System3.swift
//  
//
//  Created by rrbox on 2023/10/24.
//

class System3<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>: SystemExecute {
    let execute: (P0, P1, P2) -> ()
    
    init(_ execute: @escaping (P0, P1, P2) -> ()) {
        self.execute = execute
    }
    
    override func execute(_ worlfBuffer: WorldStorageRef) {
        self.execute(P0.getParameter(from: worlfBuffer)!,
                     P1.getParameter(from: worlfBuffer)!,
                     P2.getParameter(from: worlfBuffer)!)
    }
}

public extension World {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>(
        _ schedule: Schedule,
        _ system: @escaping (P0, P1, P2) -> ()
    ) -> World {
        self.worldStorage.systemStorage.addSystem(schedule, System3(system))
        P0.register(to: self.worldStorage)
        P1.register(to: self.worldStorage)
        P2.register(to: self.worldStorage)
        return self
    }
}

public extension EventResponderBuilder {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter>(
        _ schedule: Schedule,
        _ system: @escaping (P0, P1, P2) -> ()
    ) -> EventResponderBuilder {
        if !self.systems.keys.contains(schedule) {
            self.systems[schedule] = []
        }
        
        self.systems[schedule]?.append(System3<P0, P1, P2>(system))
        P0.register(to: self.worldStorage)
        P1.register(to: self.worldStorage)
        P2.register(to: self.worldStorage)
        return self
    }
}
