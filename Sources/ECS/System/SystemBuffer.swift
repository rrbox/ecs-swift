//
//  SystemStorage.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public class SystemExecute {
    init() {}
    public func execute(_ worldStorage: WorldStorageRef) {}
}

final public class SystemStorage {
    final class SystemRegisotry: WorldStorageElement {
        var systems = [Schedule: [SystemExecute]]()
    }
    
    let buffer: WorldStorageRef
    init(buffer: WorldStorageRef) {
        self.buffer = buffer
    }
    
    public func systems(_ schedule: Schedule) -> [SystemExecute] {
        self.buffer.map.valueRef(ofType: SystemRegisotry.self)!.body.systems[schedule]!
    }
    
    func registerSystemRegistry() {
        self.buffer.map.push(SystemRegisotry.init())
    }
    
    func insertSchedule(_ schedule: Schedule) {
        self.buffer.map.valueRef(ofType: SystemRegisotry.self)!.body.systems[schedule] = []
    }
    
    func addSystem(_ schedule: Schedule, _ system: SystemExecute) {
        self.buffer
            .map
            .valueRef(ofType: SystemRegisotry.self)!
            .body
            .systems[schedule]!
            .append(system)
    }
}

public extension WorldStorageRef {
    var systemStorage: SystemStorage {
        SystemStorage(buffer: self)
    }
}
