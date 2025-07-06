//
//  Resource.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

/**
 リソースとして機能する値の型を定義します.
 
- note: 詳細は <doc:Resources> を参照してください.
 */
public protocol ResourceProtocol {

}

/**
 システム内からリソースを制御します.
 
- note: 詳細は <doc:Resources> を参照してください.
 */
final public class Resource<T: ResourceProtocol>: ResourceStorageElement, SystemParameter {
    public var resource: T

    init(_ resource: T) {
        self.resource = resource
    }

    public static func register(to worldStorage: WorldStorageRef) {

    }

    public static func getParameter(from worldStorage: WorldStorageRef) -> Resource<T>? {
        worldStorage.resourceStorage.resource(ofType: T.self)
    }

}
