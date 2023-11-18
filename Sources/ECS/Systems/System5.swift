//
//  System5.swift
//  
//
//  Created by rrbox on 2023/10/24.
//

class System5<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>: SystemExecute {
    let execute: (P0, P1, P2, P3, P4) -> ()
    
    init(_ execute: @escaping (P0, P1, P2, P3, P4) -> ()) {
        self.execute = execute
    }
    
    override func execute(_ worldStorageRef: WorldStorageRef) {
        self.execute(P0.getParameter(from: worldStorageRef)!,
                     P1.getParameter(from: worldStorageRef)!,
                     P2.getParameter(from: worldStorageRef)!,
                     P3.getParameter(from: worldStorageRef)!,
                     P4.getParameter(from: worldStorageRef)!)
    }
}

public extension World {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter, P2: SystemParameter, P3: SystemParameter, P4: SystemParameter>(
        _ schedule: Schedule,
        _ system: @escaping (P0, P1, P2, P3, P4) -> ()
    ) -> World {
        self.worldStorage.systemStorage.addSystem(schedule, System5(system))
        P0.register(to: self.worldStorage)
        P1.register(to: self.worldStorage)
        P2.register(to: self.worldStorage)
        P3.register(to: self.worldStorage)
        P4.register(to: self.worldStorage)
        return self
    }
}
