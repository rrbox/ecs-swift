//
//  SystemParameter.swift
//  
//
//  Created by rrbox on 2023/08/10.
//

/// 定義済みの system parameter についての詳細は <doc:SystemParameters> を参照してください.
///
/// - note: カスタムのパラメータを定義する場合にこのプロトコルを使用してください.
public protocol SystemParameter: AnyObject {
    static func register(to worldStorage: WorldStorageRef) async
    static func getParameter(from worldStorage: WorldStorageRef) async -> Self?
}

