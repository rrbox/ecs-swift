//
//  SystemBuffer.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

open class SystemExecute {
    public init() {}
}

final public class SystemBuffer {
    final class SystemRegisotry<Execute: SystemExecute>: WorldStorageElement {
        var systems = [Execute]()
    }
    
    let buffer: BufferRef
    init(buffer: BufferRef) {
        self.buffer = buffer
    }
    
    public func systems<System: SystemExecute>(ofType: System.Type) -> [System] {
        self.buffer.map.valueRef(ofType: SystemRegisotry<System>.self)!.body.systems
    }
    
    func registerSystemRegistry<System: SystemExecute>(ofType type: System.Type) {
        self.buffer.map.push(SystemRegisotry<System>.init())
    }
    
    func addSystem<System: SystemExecute>(_ system: System, as type: System.Type) {
        self.buffer
            .map
            .valueRef(ofType: SystemRegisotry<System>.self)!
            .body
            .systems
            .append(system)
    }
}

public extension BufferRef {
    var systemBuffer: SystemBuffer {
        SystemBuffer(buffer: self)
    }
}
