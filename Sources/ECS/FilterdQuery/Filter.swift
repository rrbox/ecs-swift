//
//  Filter.swift
//  
//
//  Created by rrbox on 2023/09/17.
//

public protocol Filter {
    static func condition(forEntityRecord entityRecord: EntityRecord) -> Bool
}

public struct With<T: Component>: Filter {
    public static func condition(forEntityRecord entityRecord: EntityRecord) -> Bool {
        entityRecord.component(ofType: ComponentRef<T>.self) != nil
    }
}

public struct WithOut<T: Component>: Filter {
    public static func condition(forEntityRecord entityRecord: EntityRecord) -> Bool {
        entityRecord.component(ofType: ComponentRef<T>.self) == nil
    }
}

public struct And<T: Filter, U: Filter>: Filter {
    public static func condition(forEntityRecord entityRecord: EntityRecord) -> Bool {
        T.condition(forEntityRecord: entityRecord) && U.condition(forEntityRecord: entityRecord)
    }
}

public struct Or<T: Filter, U: Filter>: Filter {
    public static func condition(forEntityRecord entityRecord: EntityRecord) -> Bool {
        T.condition(forEntityRecord: entityRecord) || U.condition(forEntityRecord: entityRecord)
    }
}
