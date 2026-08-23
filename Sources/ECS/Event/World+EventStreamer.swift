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
        worldStorage.eventStorage.registerEventStreamer(eventType: T.self)
        return self
    }
}

extension World {
    func addRemovedEventStreamer() {
        worldStorage.eventStorage.registerRemovedEventStreamer()
    }
}

extension World {
    func applyEventQueue() {
        let queues = worldStorage.eventStorage.eventQueues()!
        for queue in queues.body {
            queue.applyEventsWritingBuffer()
        }
    }

    func applyRemovedEventQueue() {
        let eventStorage = self.worldStorage.eventStorage
        let receiver = eventStorage.removedEventReceiver()
        receiver?.receive(worldStorage: worldStorage)
    }
}

public extension World {
    /**
     ``World`` インスタンスを介して Event を配信します.

     System 内で Event を発信する場合は ``EventWriter`` を参照してください.
     */
    func sendEvent<T: EventProtocol>(_ value: T) {
        self.worldStorage.eventStorage.eventWriter(typeOf: T.self)?.send(value)
    }
}
