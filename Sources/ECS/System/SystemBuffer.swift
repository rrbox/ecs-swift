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
    final class SystemRegisotry<Execute: SystemExecute>: BufferElement {
        var systems = [Execute]()
    }
    
    let buffer: Buffer
    init(buffer: Buffer) {
        self.buffer = buffer
    }
    
    public func systems<System: SystemExecute>(ofType: System.Type) -> [System] {
        self.buffer.component(ofType: SystemRegisotry<System>.self)!.systems
    }
    
    func registerSystemRegistry<System: SystemExecute>(ofType type: System.Type) {
        self.buffer.addComponent(SystemRegisotry<System>.init())
    }
    
    func addSystem<System: SystemExecute>(_ system: System, as type: System.Type) {
        self.buffer
            .component(ofType: SystemRegisotry<System>.self)!
            .systems
            .append(system)
    }
}

public extension WorldBuffer {
    var systemBuffer: SystemBuffer {
        SystemBuffer(buffer: self)
    }
}
