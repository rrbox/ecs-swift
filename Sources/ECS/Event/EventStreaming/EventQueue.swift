//
//  EventQueue.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

class EventQueue: WorldStorageElement {
    var eventQueue = [AnyEvent]()
    var sendingEvents = [AnyEvent]()
}
