//
//  FirstFrame.swift
//
//
//  Created by rrbox on 2023/11/20.
//

class FirstFrameCommand: Command {
    override func runCommand(in world: World) {
        world.updateSchedule = .update
    }
}

// Delta time resource の設定のため, 一番最初のフレームはスキップします.
func firstFrameSystem(commands: Commands) {
    commands.push(command: FirstFrameCommand())
}
