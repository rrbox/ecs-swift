//
//  State.swift
//
//
//  Created by rrbox on 2023/10/28.
//

public protocol StateProtocol: Hashable {

}

class StateRegistry<T: StateProtocol>: WorldStorageElement {
    var currentState: T
    var inactiveStates = [T]()

    init(currentState: T) {
        self.currentState = currentState
    }
}

public class StateStorage {
    class StateAssociatedSchedules: WorldStorageElement {
        var schedules = Set<Schedule>()
        var eventSchedules = Set<EventSchedule>()
    }

    class StateTransitionQueue: WorldStorageElement {
        private(set) var didEnterQueue = [Schedule]()
        private(set) var willExitQueue = [Schedule]()
        private(set) var onResumeQueue = [Schedule]()
        private(set) var onPauseQueue = [Schedule]()
        private(set) var onUpdateNewStateQueue = [Schedule]()
        private(set) var onUpdatePreviousStateQueue = [Schedule]()
        private(set) var onStackUpdateNewStateQueue = [Schedule]()
        private(set) var onStackUpdatePreviousStateQueue = [Schedule]()
        private(set) var onInactiveUpdateNewStateQueue = [Schedule]()
        private(set) var onInactiveUpdatePreviousStateQueue = [Schedule]()

        private(set) var didEnterEventQueue = [EventSchedule]()
        private(set) var willExitEventQueue = [EventSchedule]()
        private(set) var onResumeEventQueue = [EventSchedule]()
        private(set) var onPauseEventQueue = [EventSchedule]()
        private(set) var onUpdateNewStateEventQueue = [EventSchedule]()
        private(set) var onUpdatePreviousStateEventQueue = [EventSchedule]()
        private(set) var onStackUpdateNewStateEventQueue = [EventSchedule]()
        private(set) var onStackUpdatePreviousStateEventQueue = [EventSchedule]()
        private(set) var onInactiveUpdateNewStateEventQueue = [EventSchedule]()
        private(set) var onInactiveUpdatePreviousStateEventQueue = [EventSchedule]()

        // enter

        func enqueueEntered<T: StateProtocol>(state: T) {
            didEnterQueue.append(.didEnter(state))
            didEnterEventQueue.append(.didEnter(state))
            onUpdateNewStateQueue.append(.onUpdate(state))
            onUpdateNewStateEventQueue.append(.onUpdate(state))
            onStackUpdateNewStateQueue.append(.onStackUpdate(state))
            onStackUpdateNewStateEventQueue.append(.onStackUpdate(state))
        }

        func enqueueExited<T: StateProtocol>(state: T) {
            willExitQueue.append(.willExit(state))
            willExitEventQueue.append(.willExit(state))
            onUpdatePreviousStateQueue.append(.onUpdate(state))
            onUpdatePreviousStateEventQueue.append(.onUpdate(state))
            onStackUpdatePreviousStateQueue.append(.onStackUpdate(state))
            onStackUpdatePreviousStateEventQueue.append(.onStackUpdate(state))
        }

        // push

        func enqueuePushed<T: StateProtocol>(state: T) {
            didEnterQueue.append(.didEnter(state))
            didEnterEventQueue.append(.didEnter(state))
            onUpdateNewStateQueue.append(.onUpdate(state))
            onUpdateNewStateEventQueue.append(.onUpdate(state))
            onStackUpdateNewStateQueue.append(.onStackUpdate(state))
            onStackUpdateNewStateEventQueue.append(.onStackUpdate(state))
        }

        func enqueuePaused<T: StateProtocol>(state: T) {
            onPauseQueue.append(.onPause(state))
            onPauseEventQueue.append(.onPause(state))
            onUpdatePreviousStateQueue.append(.onUpdate(state))
            onUpdatePreviousStateEventQueue.append(.onUpdate(state))
            onInactiveUpdateNewStateQueue.append(.onInactiveUpdate(state))
            onInactiveUpdateNewStateEventQueue.append(.onInactiveUpdate(state))
        }

        // pop

        func enqueuePopped<T: StateProtocol>(state: T) {
            onUpdatePreviousStateQueue.append(.onUpdate(state))
            onUpdatePreviousStateEventQueue.append(.onUpdate(state))
            onStackUpdatePreviousStateQueue.append(.onStackUpdate(state))
            onStackUpdatePreviousStateEventQueue.append(.onStackUpdate(state))
            willExitQueue.append(.willExit(state))
            willExitEventQueue.append(.willExit(state))
        }

        func enqueueResumed<T: StateProtocol>(state: T) {
            onResumeQueue.append(.onResume(state))
            onResumeEventQueue.append(.onResume(state))
            onUpdateNewStateQueue.append(.onUpdate(state))
            onUpdateNewStateEventQueue.append(.onUpdate(state))
            onInactiveUpdatePreviousStateQueue.append(.onInactiveUpdate(state))
            onInactiveUpdatePreviousStateEventQueue.append(.onInactiveUpdate(state))
        }

        // clear

        func clear() {
            didEnterQueue = []
            willExitQueue = []
            onResumeQueue = []
            onPauseQueue = []
            onUpdatePreviousStateQueue = []
            onUpdateNewStateQueue = []
            onStackUpdatePreviousStateQueue = []
            onStackUpdateNewStateQueue = []
            onInactiveUpdatePreviousStateQueue = []
            onInactiveUpdateNewStateQueue = []

            didEnterEventQueue = []
            willExitEventQueue = []
            onResumeEventQueue = []
            onPauseEventQueue = []
            onUpdateNewStateEventQueue = []
            onUpdatePreviousStateEventQueue = []
            onStackUpdateNewStateEventQueue = []
            onStackUpdatePreviousStateEventQueue = []
            onInactiveUpdateNewStateEventQueue = []
            onInactiveUpdatePreviousStateEventQueue = []
        }
    }

    let storageRef: WorldStorageRef

    init(storageRef: WorldStorageRef) {
        self.storageRef = storageRef
    }

    func setUp() {
        self.storageRef.map.push(StateAssociatedSchedules())
        self.storageRef.map.push(StateTransitionQueue())
    }

    func registerState<T: StateProtocol>(initialState: T, states: [T]) {
        self.storageRef.map.push(StateRegistry(currentState: initialState))
        let queue = self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!.body
        queue.enqueueEntered(state: initialState)
    }

    func currentState<T: StateProtocol>(ofType type: T.Type) -> T? {
        self.storageRef.map.valueRef(ofType: StateRegistry<T>.self)?.body.currentState
    }

    func currentSchedulesWhichAssociatedStates() -> Set<Schedule> {
        self.storageRef.map.valueRef(ofType: StateAssociatedSchedules.self)!.body.schedules
    }

    func currentEventSchedulesWhichAssociatedStates() -> Set<EventSchedule> {
        self.storageRef.map.valueRef(ofType: StateAssociatedSchedules.self)!.body.eventSchedules
    }

    // MARK: - queue

    func didEnterQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .didEnterQueue
    }

    func willExitQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .willExitQueue
    }

    func onPauseQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .onPauseQueue
    }

    func onResumeQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .onResumeQueue
    }

    func onUpdatePreviousStateQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .onUpdatePreviousStateQueue
    }

    func onStackUpdatePreviousStateQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .onStackUpdatePreviousStateQueue
    }

    func onUpdateNewStateQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .onUpdateNewStateQueue
    }

    func onStackUpdateNewStateQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .onStackUpdateNewStateQueue
    }

    func onInactiveNewStateQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .onInactiveUpdateNewStateQueue
    }

    func onInactivePreviousStateQueue() -> [Schedule] {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body
            .onInactiveUpdatePreviousStateQueue
    }

    func clearQueue() {
        self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!
            .body.clear()
    }

    // MARK: - commands

    func enter<T: StateProtocol>(_ state: T) {
        let stateRegistry = self.storageRef.map.valueRef(ofType: StateRegistry<T>.self)!.body
        let queue = self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!.body
        let previous = stateRegistry.currentState

        queue.enqueueExited(state: previous)
        queue.enqueueEntered(state: state)
        stateRegistry.currentState = state
    }

    func push<T: StateProtocol>(_ state: T) {
        let stateRegistry = self.storageRef.map.valueRef(ofType: StateRegistry<T>.self)!.body
        let queue = self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!.body
        let previous = stateRegistry.currentState

        queue.enqueuePaused(state: previous)
        queue.enqueuePushed(state: state)
        stateRegistry.inactiveStates.append(previous)
        stateRegistry.currentState = state
    }

    func pop<T: StateProtocol>(_ stateType: T.Type) {
        let registry = self.storageRef.map.valueRef(ofType: StateRegistry<T>.self)!.body
        let queue = self.storageRef.map.valueRef(ofType: StateTransitionQueue.self)!.body
        let previeous = registry.currentState
        let new = registry.inactiveStates.removeLast()

        queue.enqueuePopped(state: previeous)
        queue.enqueueResumed(state: new)
        registry.currentState = new
    }

}

public extension WorldStorageRef {
    var stateStorage: StateStorage {
        StateStorage(storageRef: self)
    }
}

public extension World {
    /// Adds a set of states to the world and registers their associated schedules.
    ///
    /// - Parameters:
    ///   - initialState: The initial state to be registered. This state must conform to `StateProtocol`.
    ///   - states: An array of states to be added to the world. Each state must conform to `StateProtocol`.
    /// - Returns: The current `World` instance, allowing for method chaining.
    ///
    /// This method performs the following actions:
    /// 1. Registers the initial state and the provided states with the world's state storage.
    /// 2. For each state in the `states` array, it inserts the following schedules into the world's system storage:
    ///    - `.onUpdate`: Called when the state is updated.
    ///    - `.onInactiveUpdate`: Called when the state is updated while inactive.
    ///    - `.onStackUpdate`: Called when the state is updated while on the stack.
    ///    - `.didEnter`: Called when the state is entered. This is also invoked for the initialState during the world's startup phase.
    ///    - `.willExit`: Called when the state is about to exit.
    ///    - `.onPause`: Called when the state is paused.
    ///    - `.onResume`: Called when the state is resumed.
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
