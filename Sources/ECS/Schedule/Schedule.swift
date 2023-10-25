//
//  Schedule.swift
//
//
//  Created by rrbox on 2023/10/22.
//

public struct Schedule: Hashable {
    let id: AnyHashable
}

enum DefaultSchedule {
    case startUp
    case update
}

public extension Schedule {
    static let startUp: Schedule = Schedule(id: DefaultSchedule.startUp)
    static let update: Schedule = Schedule(id: DefaultSchedule.update)
}
