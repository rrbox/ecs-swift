//
//  StateAssociatedEventSchedules.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/06/15.
//

public extension EventSchedule {
    /// `state` が active の間の ``World/update(currentTime:)`` 実行時にイベントを受信します.
    static func onUpdate<T: StateProtocol>(_ state: T) -> EventSchedule {
        EventSchedule(id: OnUpdate(value: state))
    }

    /// `state` が inactive の間の ``World/update(currentTime:)`` 実行時にイベントを受信します.
    static func onInactiveUpdate<T: StateProtocol>(_ state: T) -> EventSchedule {
        EventSchedule(id: OnInactiveUpdate(value: state))
    }

    /// `state` が active/inactive 関係なくスタックされている間の ``World/update(currentTime:)`` 実行時にイベントを受信します.
    static func onStackUpdate<T: StateProtocol>(_ state: T) -> EventSchedule {
        EventSchedule(id: OnStackUpdate(value: state))
    }

    /// `state` を active にした時にイベントを受信します.
    static func didEnter<T: StateProtocol>(_ state: T) -> EventSchedule {
        EventSchedule(id: DidEnter(value: state))
    }

    /// `state` を inactive にした時にイベントを受信します.
    static func willExit<T: StateProtocol>(_ state: T) -> EventSchedule {
        EventSchedule(id: WillExit(value: state))
    }

    /// `state` を pause した時にイベントを受信します.
    static func onPause<T: StateProtocol>(_ state: T) -> EventSchedule {
        EventSchedule(id: OnPause(value: state))
    }

    /// `state` が resume された時にイベントを受信します.
    static func onResume<T: StateProtocol>(_ state: T) -> EventSchedule {
        EventSchedule(id: OnResume(value: state))
    }
}

