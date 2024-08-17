//
//  ObjectLinkPlugIn.swift
//  
//
//  Created by rrbox on 2023/08/05.
//

import ECS

public struct Object<T: AnyObject>: Component {
    unowned let object: T
    public init(object: T) {
        self.object = object
    }
}

extension Commands {

}
