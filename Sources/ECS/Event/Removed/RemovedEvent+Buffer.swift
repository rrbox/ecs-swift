//
//  RemovedEvent+Buffer.swift
//
//
//  Created by rrbox on 2023/08/29.
//

extension AnyMap<EventStorage> {
    mutating func registerRemovedEventStreamer() {
        let receiver = RemovedEventReceiver()
        push(receiver)
    }

    func removedEventReceiver() -> RemovedEventReceiver? {
        valueRef(ofType: RemovedEventReceiver.self)?.body
    }
}
