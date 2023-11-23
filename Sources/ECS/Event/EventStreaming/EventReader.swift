//
//  EventReader.swift
//  
//
//  Created by rrbox on 2023/08/14.
//

final public class EventReader<T>: SystemParameter, WorldStorageElement {
    public let value: T
    
    init(value: T) {
        self.value = value
    }
    
    public static func register(to worldStorage: WorldStorageRef) {
        
    }
    
    public static func getParameter(from worldStorage: WorldStorageRef) -> EventReader<T>? {
        return worldStorage.map.valueRef(ofType: EventReader<T>.self)?.body
    }
}
