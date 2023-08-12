//
//  SystemBuffer.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

open class SystemExecute {
    
}

final class SystemRegisotry<Execute: SystemExecute>: BufferElement {
    var systems = [Execute]()
}

class SystemBuffer {
    let buffer: Buffer
    init(buffer: Buffer) {
        self.buffer = buffer
    }
    
    func plugInSystems<System: SystemExecute>(ofType: System.Type) -> [System] {
        self.buffer.component(ofType: SystemRegisotry<System>.self)!.systems
    }
    
    func registerPlugIn<System: SystemExecute>(ofType type: System.Type) {
        self.buffer.addComponent(SystemRegisotry<System>.init())
    }
    
    func addPlugInSystem<System: SystemExecute>(_ system: System, as type: System.Type) {
        self.buffer
            .component(ofType: SystemRegisotry<System>.self)!
            .systems
            .append(system)
    }
}
