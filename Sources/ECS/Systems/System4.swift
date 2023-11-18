//
//  System4.swift
//  
//
//  Created by rrbox on 2023/10/24.
//

class System4<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter>: SystemExecute {
    let execute: (P0, P1, P2, P3) -> ()
    
    init(_ execute: @escaping (P0, P1, P2, P3) -> ()) {
        self.execute = execute
    }
    
    override func execute(_ worldStorageRef: WorldStorageRef) {
        self.execute(P0.getParameter(from: worldStorageRef)!,
                     P1.getParameter(from: worldStorageRef)!,
                     P2.getParameter(from: worldStorageRef)!,
                     P3.getParameter(from: worldStorageRef)!)
    }
}

public extension World {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter>(
        _ schedule: Schedule,
        _ system: @escaping (P0, P1, P2, P3) -> ()
    ) -> World {
        self.worldStorage.systemStorage.addSystem(schedule, System4(system))
        P0.register(to: self.worldStorage)
        P1.register(to: self.worldStorage)
        P2.register(to: self.worldStorage)
        P3.register(to: self.worldStorage)
        return self
    }
}

public extension EventResponderBuilder {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter>(
        _ schedule: Schedule,
        _ system: @escaping (P0, P1, P2, P3) -> ()
    ) -> EventResponderBuilder {
        if !self.systems.keys.contains(schedule) {
            self.systems[schedule] = []
        }
        
        self.systems[schedule]?.append(System4<P0, P1, P2, P3>(system))
        P0.register(to: self.worldStorage)
        P1.register(to: self.worldStorage)
        P2.register(to: self.worldStorage)
        P3.register(to: self.worldStorage)
        return self
    }
}
