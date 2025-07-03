//
//  WorldStorage.swift
//  
//
//  Created by rrbox on 2023/10/22.
//

protocol WorldStorageType {}

public protocol WorldStorageElement {}

final public class Box<T: WorldStorageElement>: Item {
    private(set) var body: T

    init(body: T) {
        self.body = body
    }
}
