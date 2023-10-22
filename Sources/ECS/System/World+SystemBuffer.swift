//
//  World+SystemBuffer.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public extension World {
    @discardableResult func registerSystemRegistry<System: SystemExecute>(ofType type: System.Type) -> World {
        self.worldBuffer.systemBuffer.registerSystemRegistry(ofType: System.self)
        return self
    }
    
    /// World に system を追加します.
    ///
    /// system を追加する前に, ``World/registerSystemRegistry(ofType:)`` で system を保持するためのメモリ領域を確保する必要があります.
    @discardableResult func addSystem<System: SystemExecute>(_ system: System, as type: System.Type) -> World {
        self.worldBuffer.systemBuffer.addSystem(system, as: System.self)
        return self
    }
}
