//
//  StateAssociatedSchedules.swift
//
//
//  Created by rrbox on 2023/10/28.
//

struct OnUpdate<T: StateProtocol>: Hashable {
    let value: T
}

struct OnInactiveUpdate<T: StateProtocol>: Hashable {
    let value: T
}

struct OnStackUpdate<T: StateProtocol>: Hashable {
    let value: T
}

struct DidEnter<T: StateProtocol>: Hashable {
    let value: T
}

struct WillExit<T: StateProtocol>: Hashable {
    let value: T
}

struct OnPause<T: StateProtocol>: Hashable {
    let value: T
}

struct OnResume<T: StateProtocol>: Hashable {
    let value: T
}

public extension Schedule {
    static func onUpdate<T: StateProtocol>(_ state: T) -> Schedule {
        Schedule(id: OnUpdate(value: state))
    }
    
    static func onInactiveUpdate<T: StateProtocol>(_ state: T) -> Schedule {
        Schedule(id: OnInactiveUpdate(value: state))
    }
    
    static func onStackUpdate<T: StateProtocol>(_ state: T) -> Schedule {
        Schedule(id: OnStackUpdate(value: state))
    }
    
    static func didEnter<T: StateProtocol>(_ state: T) -> Schedule {
        Schedule(id: DidEnter(value: state))
    }
    
    static func willExit<T: StateProtocol>(_ state: T) -> Schedule {
        Schedule(id: WillExit(value: state))
    }
    
    static func onPause<T: StateProtocol>(_ state: T) -> Schedule {
        Schedule(id: OnPause(value: state))
    }
    
    static func onResume<T: StateProtocol>(_ state: T) -> Schedule {
        Schedule(id: OnResume(value: state))
    }
}
