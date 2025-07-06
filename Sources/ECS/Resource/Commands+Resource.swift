//
//  Commands+Resource.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

final class AddResource<T: ResourceProtocol>: Command {
    let resrouce: T

    init(resrouce: T) {
        self.resrouce = resrouce
    }

    override func runCommand(in world: World) {
        world.addResource(self.resrouce)
    }
}

public extension Commands {
    /// world に対して resource を追加します.
    ///
    /// resource はフレームの終了直前に追加されます.
    @discardableResult func addResource<T: ResourceProtocol>(_ resource: T) -> Commands {
        self.push(command: AddResource(resrouce: resource))
        return self
    }
}
