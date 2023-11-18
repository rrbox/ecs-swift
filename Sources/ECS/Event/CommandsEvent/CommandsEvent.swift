//
//  CommandsEvent.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

/// Commands 実行中に発信されるイベントです.
protocol CommandsEventProtocol {
    
}

struct OnCommandsEvent<T: CommandsEventProtocol>: Hashable {
    
}

extension Schedule {
    static func onCommandsEvent<T: CommandsEventProtocol>(ofType type: T.Type) -> Schedule {
        Schedule(id: OnCommandsEvent<T>())
    }
}
