//
//  World+PlugIn.swift
//  
//
//  Created by rrbox on 2023/08/19.
//

public extension World {
    @discardableResult func addPlugIn(_ execute: (World) -> ()) -> World {
        execute(self)
        return self
    }
}
