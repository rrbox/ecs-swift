//
//  State.swift
//
//
//  Created by rrbox on 2023/10/15.
//

class StateDependentSystemBuffer {
    class StateSystemRegistry<State: Hashable, System: SystemExecute>: BufferElement {
        var stateSystemMap: [State: [System]] = [:]
    }
    
    let buffer: Buffer
    init(buffer: Buffer) {
        self.buffer = buffer
    }
    
    public func systems<System: SystemExecute, State: Hashable>(
        ofType: System.Type,
        forState state: State
    ) -> [System] {
        self.buffer.component(ofType: StateSystemRegistry<State, System>.self)!.stateSystemMap[state]!
    }
    
    public func addSystem<System: SystemExecute, State: Hashable>(
        _ system: System,
        as: System.Type,
        forState state: State
    ) {
        let registry = self.buffer.component(ofType: StateSystemRegistry<State, System>.self)!
        if registry.stateSystemMap[state] == nil {
            registry.stateSystemMap[state] = [system]
        } else {
            registry.stateSystemMap[state]?.append(system)
        }
    }
    
    
}
