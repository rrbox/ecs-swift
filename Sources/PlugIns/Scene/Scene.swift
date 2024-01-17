//
//  Scene.swift
//  
//
//  Created by rrbox on 2023/08/06.
//

import SpriteKit
import ECS

open class Scene: SKScene {
    var _world: World!
    
    open func buildWorld() -> World {
        World()
    }
    
    public var world: World {
        self._world
    }
    
    final public override func didMove(to view: SKView) {
        self._world = self.buildWorld()
        Task {
            await self._world?.setUpWorld()
        }
    }
    
    final public override func update(_ currentTime: TimeInterval) {
        Task {
            await self._world?.update(currentTime: currentTime)
        }
    }
    
    public func restartWorld() async {
        self._world = self.buildWorld()
        await self._world.setUpWorld()
    }
    
}
