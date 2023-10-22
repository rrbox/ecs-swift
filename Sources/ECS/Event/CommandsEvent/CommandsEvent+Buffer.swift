//
//  CommandsEvent+Buffer.swift
//  
//
//  Created by rrbox on 2023/08/29.
//

import Foundation

class CommadsEventWriterRegistry<T: CommandsEventProtocol>: BufferElement {
    let writer: CommandsEventWriter<T>
    init(writer: CommandsEventWriter<T>) {
        self.writer = writer
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EventBuffer {
    func setUpCommandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) {
        self.buffer.addComponent(CommandsEventQueue<T>())
    }
    
    func commandsEventQueue<T: CommandsEventProtocol>(eventOfType: T.Type) -> CommandsEventQueue<T>? {
        self.buffer.component(ofType: CommandsEventQueue<T>.self)
    }
    
    func commandsEventWriter<T>(eventOfType type: T.Type) -> CommandsEventWriter<T>? {
        self.buffer.component(ofType: CommadsEventWriterRegistry<T>.self)?.writer
    }
    
    func registerCommandsEventWriter<T: CommandsEventProtocol>(eventType: T.Type) {
        let eventQueue = self.buffer.component(ofType: CommandsEventQueue<T>.self)!
        self.buffer.addComponent(CommadsEventWriterRegistry<T>(writer: CommandsEventWriter<T>(eventQueue: eventQueue)))
    }
}
