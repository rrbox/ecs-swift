//
//  StateControll.swift
//
//
//  Created by rrbox on 2023/10/28.
//

final public class State<T: StateProtocol>: SystemParameter {
    let stateStrageRef: StateStorage
    let currentState: T
    
    init?(stateStrageRef: StateStorage, currentStaete: T?) {
        guard let currentStaete = currentStaete else { return nil }
        self.stateStrageRef = stateStrageRef
        self.currentState = currentStaete
    }
    
    public static func register(to worldStorage: WorldStorageRef) {
        
    }
    
    public static func getParameter(from worldStorage: WorldStorageRef) -> State<T>? {
        State<T>(stateStrageRef: worldStorage.stateStorage,
                 currentStaete: worldStorage.stateStorage.currentState(ofType: T.self))
    }
    
    public func enter(_ state: T) {
        self.stateStrageRef.enter(state)
    }
    
    public func push(_ state: T) {
        self.stateStrageRef.push(state)
    }
    
    public func pop() {
        self.stateStrageRef.pop(T.self)
    }
    
}
