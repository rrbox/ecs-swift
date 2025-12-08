//
//  EventReceiver.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/07/06.
//

final class EventQueues: EventStorageElement {
    var body = [any AnyEventQueue]()
}

protocol AnyEventQueue {
    func applyEventsWritingBuffer()
}

final class EventQueue<T: EventProtocol>: AnyEventQueue, EventStorageElement {
    var eventWritingBuffer = [T]()
    // 3フェーズ分の event buffer を1フレームの間キャッシュする
    var eventBufferQueue: [[T]] = [[], [], []]

    var countOfEvents: Int {
        eventBufferQueue.reduce(0) { $0 + $1.count }
    }

    func write(event: T) {
        eventWritingBuffer.append(event)
    }

    func applyEventsWritingBuffer() {
        eventBufferQueue.removeFirst()
        eventBufferQueue.append(eventWritingBuffer)
        eventWritingBuffer.removeAll()
    }

    func forEach(_ body: (T) -> ()) {
        eventBufferQueue.forEach { eventsBuffer in
            eventsBuffer.forEach(body)
        }
    }
}
