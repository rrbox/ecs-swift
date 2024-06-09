//
//  AddBundle.swift
//  
//
//  Created by rrbox on 2024/06/09.
//

class AddBundle<T: BundleProtocol>: EntityCommand {
    let bundle: T
    
    init(entity: Entity, bundle: T) {
        self.bundle = bundle
        super.init(entity: entity)
    }
    
    override func runCommand(forRecord record: EntityRecordRef, inWorld world: World) {
        bundle.addComponent(forEntity: record)
    }
}
