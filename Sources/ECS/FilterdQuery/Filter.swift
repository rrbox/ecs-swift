//
//  Filter.swift
//  
//
//  Created by rrbox on 2023/09/17.
//

public protocol Filter {
    static func condition(forEntityRecord entityRecord: EntityRecordRef) -> Bool
}

public struct With<T: Component>: Filter {
    public static func condition(forEntityRecord entityRecord: EntityRecordRef) -> Bool {
        entityRecord.componentRef(T.self) != nil
    }
}

public struct WithOut<T: Component>: Filter {
    public static func condition(forEntityRecord entityRecord: EntityRecordRef) -> Bool {
        entityRecord.componentRef(T.self) == nil
    }
}

public struct And<T: Filter, U: Filter>: Filter {
    public static func condition(forEntityRecord entityRecord: EntityRecordRef) -> Bool {
        T.condition(forEntityRecord: entityRecord) && U.condition(forEntityRecord: entityRecord)
    }
}

public struct Or<T: Filter, U: Filter>: Filter {
    public static func condition(forEntityRecord entityRecord: EntityRecordRef) -> Bool {
        T.condition(forEntityRecord: entityRecord) || U.condition(forEntityRecord: entityRecord)
    }
}
