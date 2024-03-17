//
//  EntityGenerator.swift
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
