//
//  Schedule.swift
//
//
//  Created by rrbox on 2023/10/22.
//

/**
 システムが実行されるタイミングを指定します.
 
 Eccentials
 
 - ``Schedule/startUp``
 - ``Schedule/update``
 
 State associated schedules
 
 - ``Schedule/didEnter(_:)``
 - ``Schedule/willExit(_:)``
 - ``Schedule/onUpdate(_:)``
 - ``Schedule/onInactiveUpdate(_:)``
 - ``Schedule/onStackUpdate(_:)``
 - ``Schedule/onPause(_:)``
 - ``Schedule/onResume(_:)``
 
 Entity spawn / despawn
 
 - ``Schedule/didSpawn``
 - ``Schedule/willDespawn``
 */
public struct Schedule: Hashable {
    let typeId: ObjectIdentifier
    let id: AnyHashable

    init<T: Hashable>(id: T) {
        self.typeId = ObjectIdentifier(T.self)
        self.id = id
    }
}

enum DefaultSchedule {
    case preStartUp
    case startUp
    case postStartUp
    case preUpdate
    case update
    case postUpdate
}

public extension Schedule {
    static let preStartUp: Schedule = .init(id: DefaultSchedule.preStartUp)
    /**
     ``World/setUpWorld()`` 実行時にシステムを実行します.

     ```swift
     func createEntity(commands: Commands) {
         commands.spawn() // entity
     }

     let world = World()
         .addSystem(.startUp, createEntity(commands:))

     world.setUpWorld() // entity spawn here
     ```
     */
    static let startUp: Schedule = Schedule(id: DefaultSchedule.startUp)
    static let postStartUp: Schedule = .init(id: DefaultSchedule.postStartUp)
    static let preUpdate: Schedule = .init(id: DefaultSchedule.preUpdate)
    /**
     ``World/update(currentTime:)`` 実行時にシステムを実行します.

     ```swift
     struct Name: Component {
         let value: String
     }

     func createEntity(commands: Commands) {
         commands.spawn() // entity
             .addComponent(Name(value: "Entity_0"))
     }

     func echoEntityName(query: Query<Name>) {
         query.update { _, name in
             print(name) // echo entity name
         }
     }

     let world = World()
         .addSystem(.startUp, createEntity(commands:))
         .addSystem(.update, echoEntityName(query: Query<Name>)) // system as `update`

     world.setUpWorld() // entity spawn here

     world.update(currentTime: 0) // prepareing frame
     world.update(currentTime: 1) // "Entity_0"
     world.update(currentTime: 2) // "Entity_0"
     ```
     */
    static let update: Schedule = Schedule(id: DefaultSchedule.update)
    static let postUpdate: Schedule = .init(id: DefaultSchedule.postUpdate)

    static func customSchedule<T: Hashable>(_ value: T) -> Schedule {
        Schedule(id: value)
    }
}
