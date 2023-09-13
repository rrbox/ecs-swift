//
//  EventQueue.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

class EventQueue: BufferElement {
    var eventQueue = [AnyEvent]()
    var sendingEvents = [AnyEvent]()
}
