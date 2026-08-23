//
//  RemovedEventReceiver.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/07/06.
//

final class RemovedEventReceiver: AnyEventReceiver, EventStorageElement {
    private var eventWritingBuffer = [Entity]()

    var count: Int {
        eventWritingBuffer.count
    }

    override func receive(worldStorage: WorldStorageRef) {
        let removedEntities = eventWritingBuffer
        guard !removedEntities.isEmpty else {
            return
        }
        eventWritingBuffer.removeAll()
        worldStorage.eventStorage.push(Removed(entities: removedEntities))
        for system in worldStorage.systemStorage.systems(.removed) {
            system.execute(worldStorage)
        }

        for schedule in worldStorage.stateStorage.currentRemovedSchedulesWhichAssociatedStates() {
            let systems = worldStorage.systemStorage.systems(schedule)
            for system in systems {
                system.execute(worldStorage)
            }
        }
        worldStorage.eventStorage.pop(Removed.self)
    }

    func pushDespawned(_ entity: Entity) {
        eventWritingBuffer.append(entity)
    }

    func forEach(_ body: (Entity) -> ()) {
        eventWritingBuffer.forEach(body)
    }
}
