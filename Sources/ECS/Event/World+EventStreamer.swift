//
//  World+EventStreamer.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

public extension World {
    /// `T` 型の値をイベントとして送受信するためのセットアップです.
    ///
    /// `Event<T>` をイベントシステムで扱う前に, World に EventStreamer を追加する必要があります.
    @discardableResult func addEventStreamer<T: EventProtocol>(eventType: T.Type) -> World {
        worldStorage.eventStorage.registerEventReceiver(eventType: T.self)
        worldStorage.eventStorage.registerEventWriter(eventType: T.self)
        worldStorage.eventStorage.registerEventResponder(eventType: T.self)
        return self
    }
}

extension World {
    func addCommandsEventStreamer<T: CommandsEventProtocol>(eventType: T.Type) {
        worldStorage.systemStorage.insertSchedule(.onCommandsEvent(ofType: T.self))
        worldStorage.eventStorage.registerCommandsEventReceiver(eventType: T.self)
        worldStorage.eventStorage.registerCommandsEventWriter(eventType: T.self)
        worldStorage.eventStorage.resisterCommandsEventResponder(eventType: T.self)
    }
}

extension World {
    func applyEventQueue() {
        let receivers = self.worldStorage.eventStorage.eventReceivers()!
        for receiver in receivers.eventReceivers {
            receiver.receive(worldStorage: worldStorage)
        }
    }

    func applyCommandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) {
        let eventStorage = self.worldStorage.eventStorage
        let receiver = eventStorage.commandsEventReceiver(eventOfType: T.self)!
        receiver.receive(worldStorage: worldStorage)
    }
}

public extension World {
    /**
     ``World`` インスタンスを介して Event を配信します.

     System 内で Event を発信する場合は ``EventWriter`` を参照してください.
     */
    func sendEvent<T: EventProtocol>(_ value: T) {
        self.worldStorage.eventStorage.eventWriter(eventOfType: T.self)?.send(value: value)
    }
}
