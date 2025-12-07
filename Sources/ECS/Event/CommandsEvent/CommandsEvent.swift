//
//  CommandsEvent.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

/// Commands 実行中に発信されるイベントです.
@available(*, deprecated)
protocol CommandsEventProtocol {

}

@available(*, deprecated)
struct OnCommandsEvent<T: CommandsEventProtocol>: Hashable {

}

@available(*, deprecated)
extension Schedule {
    static func onCommandsEvent<T: CommandsEventProtocol>(ofType type: T.Type) -> Schedule {
        Schedule(id: OnCommandsEvent<T>())
    }
}
