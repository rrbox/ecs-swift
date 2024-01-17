//
//  State.swift
//
//
//  Created by rrbox on 2023/10/28.
//

public protocol StateProtocol: Hashable {
    
}

public final class StateStorage {
    actor StateRegistry<T: StateProtocol>: WorldStorageElement {
        var currentState: T
        var inactiveStates = [T]()
        
        init(currentState: T) {
            self.currentState = currentState
        }
        
        func setState(_ state: T) {
            self.currentState = state
        }
        
        func push(_ state: T) {
            self.inactiveStates.append(state)
        }
        
        func pop() -> T {
            self.inactiveStates.removeLast()
        }
    }
    
    class StateAssociatedSchedules: WorldStorageElement {
        var schedules = Set<Schedule>()
    }
    
    class StatesDidEnterInStartUp: WorldStorageElement {
        // world 構築時に初期値として設定された state を一時的に保持します.
        // world の start up 時に didEnter system が実行されます.
        // start up 実行後も保持され続けられるため, world 初期化のために start up を実行した場合も同じ効果が得られます.
        var schedules = Set<Schedule>()
    }
    
    let storageRef: WorldStorageRef
    
    init(storageRef: WorldStorageRef) {
        self.storageRef = storageRef
    }
    
    func setUp() {
        self.storageRef.map.push(StateAssociatedSchedules())
        self.storageRef.map.push(StatesDidEnterInStartUp())
    }
    
    func registerState<T: StateProtocol>(initialState: T, states: [T]) {
        self.storageRef.map.push(StateRegistry(currentState: initialState))
        self.storageRef.map.valueRef(ofType: StateAssociatedSchedules.self)!.body.schedules.insert(.onUpdate(initialState))
        self.storageRef.map.valueRef(ofType: StatesDidEnterInStartUp.self)!.body.schedules.insert(.didEnter(initialState))
    }
    
    func currentState<T: StateProtocol>(ofType type: T.Type) async -> T? {
        await self.storageRef.map.valueRef(ofType: StateRegistry<T>.self)?.body.currentState
    }
    
    func currentSchedulesWhichAssociatedStates() -> Set<Schedule> {
        self.storageRef.map.valueRef(ofType: StateAssociatedSchedules.self)!.body.schedules
    }
    
    func enter<T: StateProtocol>(_ state: T) async {
        let stateRegistry = self.storageRef.map.valueRef(ofType: StateRegistry<T>.self)!.body
        let schedulesManager = self.storageRef.map.valueRef(ofType: StateAssociatedSchedules.self)!.body
        
        await schedulesManager.schedules.remove(.onUpdate(stateRegistry.currentState))
        await schedulesManager.schedules.remove(.onStackUpdate(stateRegistry.currentState))
        
        // will exit
        for system in await self.storageRef.systemStorage.systems(.willExit(stateRegistry.currentState)) {
            await system.execute(self.storageRef)
        }
        
        await self.storageRef.map.valueRef(ofType: StateRegistry<T>.self)!.body.setState(state)
        
        // did enter
        for system in self.storageRef.systemStorage.systems(.didEnter(state)) {
            await system.execute(self.storageRef)
        }
        
        schedulesManager.schedules.insert(.onUpdate(state))
        schedulesManager.schedules.insert(.onStackUpdate(state))
    }
    
    func push<T: StateProtocol>(_ state: T) async {
        let registry = self.storageRef.map.valueRef(ofType: StateRegistry<T>.self)!.body
        let schedulesManager = self.storageRef.map.valueRef(ofType: StateAssociatedSchedules.self)!.body
        
        // on pause
        for system in await self.storageRef.systemStorage.systems(.onPause(registry.currentState)) {
            await system.execute(self.storageRef)
        }
        
        await schedulesManager.schedules.remove(.onUpdate(registry.currentState))
        await schedulesManager.schedules.insert(.onInactiveUpdate(registry.currentState))
        
        await registry.push(registry.currentState)
        await registry.setState(state)
        
        schedulesManager.schedules.insert(.onUpdate(state))
        schedulesManager.schedules.insert(.onStackUpdate(state))
        
        // did enter
        for system in self.storageRef.systemStorage.systems(.didEnter(state)) {
            await system.execute(self.storageRef)
        }
    }
    
    func pop<T: StateProtocol>(_ stateType: T.Type) async {
        let registry = self.storageRef.map.valueRef(ofType: StateRegistry<T>.self)!.body
        let schedulesManager = self.storageRef.map.valueRef(ofType: StateAssociatedSchedules.self)!.body
        
        // will exit
        for system in await self.storageRef.systemStorage.systems(.willExit(registry.currentState)) {
            await system.execute(self.storageRef)
        }
        
        await schedulesManager.schedules.remove(.onUpdate(registry.currentState))
        await schedulesManager.schedules.remove(.onStackUpdate(registry.currentState))
        
//        registry.currentState = registry.inactiveStates.removeLast()
        await registry.setState(registry.pop())
        
        // on resume
        for system in await self.storageRef.systemStorage.systems(.onResume(registry.currentState)) {
            await system.execute(self.storageRef)
        }
        
        await schedulesManager.schedules.remove(.onInactiveUpdate(registry.currentState))
        await schedulesManager.schedules.insert(.onUpdate(registry.currentState))
    }
    
}

public extension WorldStorageRef {
    var stateStorage: StateStorage {
        StateStorage(storageRef: self)
    }
}

public extension World {
    @discardableResult func addState<T: StateProtocol>(initialState: T, states: [T]) -> World {
        self.worldStorage.stateStorage.registerState(initialState: initialState, states: states)
        
        for state in states {
            self.worldStorage.systemStorage.insertSchedule(.onUpdate(state))
            self.worldStorage.systemStorage.insertSchedule(.onInactiveUpdate(state))
            self.worldStorage.systemStorage.insertSchedule(.onStackUpdate(state))
            self.worldStorage.systemStorage.insertSchedule(.didEnter(state))
            self.worldStorage.systemStorage.insertSchedule(.willExit(state))
            self.worldStorage.systemStorage.insertSchedule(.onPause(state))
            self.worldStorage.systemStorage.insertSchedule(.onResume(state))
        }
        
        return self
    }
}
