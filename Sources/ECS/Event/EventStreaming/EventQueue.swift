//
//  EventQueue.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final class EventQueue: EventStorageElement {
    var eventQueue = [AnyEvent]()
    var sendingEvents = [AnyEvent]()
}
