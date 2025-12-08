//
//  File.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/12/09.
//

final public class Removed: SystemParameter, EventStorageElement {
    public let entities: [Entity]

    init(entities: [Entity]) {
        self.entities = entities
    }

    public func forEach(_ body: (Entity) -> ()) {
        entities.forEach(body)
    }

    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> Removed? {
        worldStorage.eventStorage.valueRef(ofType: Removed.self)?.body
    }
}

