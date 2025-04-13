//
//  FirstFrame.swift
//
//
//  Created by rrbox on 2023/11/20.
//

private class PreUpdateFirstFrameCommand: Command {
    override func runCommand(in world: World) {
        world.preUpdateSchedule = .preUpdate
    }
}

private class UpdateSystemFirstFrameCommand: Command {
    override func runCommand(in world: World) {
        world.updateSchedule = .update
    }
}

private class PostUpdateFirstFrameCommand: Command {
    override func runCommand(in world: World) {
        world.postUpdateSchedule = .postUpdate
    }
}

func preUpdateSystemFirstFrameSystem(commands: Commands) {
    commands.push(command: PreUpdateFirstFrameCommand())
}

func updateSystemFirstFrameSystem(commands: Commands) {
    commands.push(command: UpdateSystemFirstFrameCommand())
}

func postUpdateSystemFirstFrameSystem(commands: Commands) {
    commands.push(command: PostUpdateFirstFrameCommand())
}
