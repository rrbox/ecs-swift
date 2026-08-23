//
//  Commands+EntityCommands.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

public extension Commands {
    /// Entity を取得して変更を加えます
    func entity(_ entity: Entity) -> SearchedEntityCommands {
        let queue = SearchedEntityCommandQueue(entity: entity)
        self.entityTransactions.append(queue)
        return SearchedEntityCommands(entity: entity, commandsQueue: queue)
    }

    /// Entity を追加して変更を加えます.
    @discardableResult func spawn() -> SpawnedEntityCommands {
        let entity = self.generator.generate()
        let record = EntityRecordRef(entity: entity)

        record.map.body[ObjectIdentifier(Entity.self)] = ImmutableRef(value: entity)

        self.generator.pop()

        self.entityTransactions.append(SpawnCommand(entityRecord: record))
        let queue = SpawnedEntityCommandQueue(record: record)
        self.entityTransactions.append(queue)

        return SpawnedEntityCommands(entity: entity, commandsQueue: queue)
    }

    /// Entity を削除します.
    ///
    /// - Important: ``Commands/spawn()`` した entity を同じ phase 内で despawn することはできません.
    /// spawn は phase の終わりに反映されるため, その entity はどのシステムからも観測されず,
    /// despawn する意味を持ちません.
    func despawn(entity: Entity) {
        self.entityTransactions.append(DespawnCommand(entity: entity))
    }
}

extension Commands {
    func recycleSlot(of entity: Entity) {
        self.generator.stack(entity: Entity(slot: entity.slot, generation: entity.generation+1))
    }
}
