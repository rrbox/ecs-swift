import Foundation

//public struct Entity: QueryTarget, Hashable {
//    let id = UUID()
//}

public struct Entity: QueryTarget, Equatable, Hashable {
    let slot: Int
    let generation: Int
}
