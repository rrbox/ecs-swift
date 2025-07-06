//
//  EventSchedule.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/06/15.
//

/**
 システムが実行されるタイミングを指定します.

 - ``EventSchedule/update``

 */
public struct EventSchedule: Hashable {
    let typeId: ObjectIdentifier
    let id: AnyHashable

    init<T: Hashable>(id: T) {
        self.typeId = ObjectIdentifier(T.self)
        self.id = id
    }
}

public extension EventSchedule {
    /**
     ``World/update(currentTime:)`` 実行時にイベントを受信します.
     */
    static let update: EventSchedule = EventSchedule(id: DefaultSchedule.update)

    static func customSchedule<T: Hashable>(_ value: T) -> EventSchedule {
        EventSchedule(id: value)
    }
}
