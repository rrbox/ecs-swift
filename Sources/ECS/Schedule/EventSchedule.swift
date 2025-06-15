//
//  EventSchedule.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/06/15.
//

/**
 システムが実行されるタイミングを指定します.

 Eccentials

 - ``Schedule/startUp``
 - ``Schedule/update``

 State associated schedules

 - ``EventSchedule/didEnter(_:)``
 - ``EventSchedule/willExit(_:)``
 - ``EventSchedule/onUpdate(_:)``
 - ``EventSchedule/onInactiveUpdate(_:)``
 - ``EventSchedule/onStackUpdate(_:)``
 - ``EventSchedule/onPause(_:)``
 - ``EventSchedule/onResume(_:)``

 Entity spawn / despawn

 - ``Schedule/didSpawn``
 - ``Schedule/willDespawn``
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
    static let update: Schedule = Schedule(id: DefaultSchedule.update)

    static func customSchedule<T: Hashable>(_ value: T) -> Schedule {
        Schedule(id: value)
    }
}
