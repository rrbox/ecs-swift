//
//  ChunkStorage.swift
//
//
//  Created by rrbox on 2023/08/11.
//

protocol ChunkStorageElement: WorldStorageElement {

}

enum ChunkStorage: WorldStorageType {

}

final public class ChunkStorageRef {
    var storage = AnyMap<ChunkStorage>()
}

extension AnyMap where Mode == ChunkStorage {
    mutating func push<T: ChunkStorageElement>(_ data: T) {
        self.body[ObjectIdentifier(T.self)] = Box(body: data)
    }

    mutating func pop<T: ChunkStorageElement>(_ type: T.Type) {
        self.body.removeValue(forKey: ObjectIdentifier(T.self))
    }

    func valueRef<T: ChunkStorageElement>(ofType type: T.Type) -> Box<T>? {
        guard let result = self.body[ObjectIdentifier(T.self)] else { return nil }
        return (result as! Box<T>)
    }
}
