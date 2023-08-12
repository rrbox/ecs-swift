//
//  Component.swift
//  
//
//  Created by rrbox on 2023/08/05.
//

import Foundation

public protocol Component {
    
}

final public class ComponentRef<ComponentType: Component>: ArchetypeComponent {
    var value: ComponentType
    
    public init(component: ComponentType) {
        self.value = component
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
