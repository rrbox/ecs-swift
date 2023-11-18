//
//  System2.swift
//  
//
//  Created by rrbox on 2023/10/24.
//

class System2<P0: SystemParameter, P1: SystemParameter>: SystemExecute {
    let execute: (P0, P1) -> ()
    
   init(_ execute: @escaping (P0, P1) -> ()) {
        self.execute = execute
    }
    
    override func execute(_ worldStorageRef: WorldStorageRef) {
        self.execute(P0.getParameter(from: worldStorageRef)!, P1.getParameter(from: worldStorageRef)!)
    }
}

public extension World {
    @discardableResult func addSystem<P0: SystemParameter, P1: SystemParameter>(_ schedule: Schedule, _ system: @escaping (P0, P1) -> ()) -> World {
        self.worldStorage.systemStorage.addSystem(schedule, System2<P0, P1>(system))
        P0.register(to: self.worldStorage)
        P1.register(to: self.worldStorage)
        return self
    }
}
