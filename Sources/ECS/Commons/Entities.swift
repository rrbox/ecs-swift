//
//  Entities.swift
//  
//
//  Created by rrbox on 2024/02/13.
//

struct EntityGenerator {
    private var reusables: [Entity] = [Entity(slot: 0, generation: 0)]
    private var lastIndex: Int = 0
    
    func generate() -> Entity {
        self.reusables[lastIndex]
    }
    
    mutating func stack(entity: Entity) {
        self.reusables.append(entity)
        self.lastIndex += 1
    }
    
    mutating func pop() {
        if self.lastIndex == 0 {
            self.reusables[0] = Entity(slot: self.reusables[0].slot+1, generation: 0)
        } else {
            self.reusables.removeLast()
            self.lastIndex -= 1
        }
    }
}

public struct _Entities {
    var data = SparseSet<EntityRecordRef>(sparse: [], dense: [], data: [])
    var entityGenerator = EntityGenerator()
    
    public init() {}
    
    public mutating func spawn() -> (Entity, EntityRecordRef) {
        let spawned = self.entityGenerator.generate()
        if spawned.generation == 0 {
            self.data.allocate()
        }
        
        let entityRecord = EntityRecordRef()
        entityRecord.map.body[ObjectIdentifier(Entity.self)] = ImmutableRef(value: spawned)
        
        self.data.insert(entityRecord, withEntity: spawned)
        self.entityGenerator.pop()
        return (spawned, entityRecord)
    }
    
    public mutating func despawn(entity: Entity) {
        self.entityGenerator.stack(entity: Entity(slot: entity.slot, generation: entity.generation+1))
        self.data.pop(entity: entity)
    }
    
}

