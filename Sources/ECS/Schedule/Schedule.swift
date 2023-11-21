//
//  Schedule.swift
//
//
//  Created by rrbox on 2023/10/22.
//

public struct Schedule: Hashable {
    let typeId: ObjectIdentifier
    let id: AnyHashable
    
    init<T: Hashable>(id: T) {
        self.typeId = ObjectIdentifier(T.self)
        self.id = id
    }
}

enum DefaultSchedule {
    case startUp
    case firstFrame
    case update
}

public extension Schedule {
    static let startUp: Schedule = Schedule(id: DefaultSchedule.startUp)
    static let update: Schedule = Schedule(id: DefaultSchedule.update)
    static func customSchedule<T: Hashable>(_ value: T) -> Schedule {
        Schedule(id: value)
    }
}

extension Schedule {
    static let firstFrame: Schedule = Schedule(id: DefaultSchedule.firstFrame)
}
