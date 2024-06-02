//
//  System.swift
//
//
//  Created by rrbox on 2024/05/06.
//

import ECS

func graphicSystem(world: World) {
    world
        .addSystem(.update, _addChildNodeSystem(query:scene:commands:))
}
