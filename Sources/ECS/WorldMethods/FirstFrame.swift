//
//  FirstFrame.swift
//
//
//  Created by rrbox on 2023/11/20.
//

class FirstFrameCommand: Command {
    override func runCommand(in world: World) async {
        world.updateSchedule = .update
    }
}

// Delta time resource の設定のため, 一番最初のフレームはスキップします.
func firstFrameSystem(commands: Commands) async {
    await commands.push(command: FirstFrameCommand())
}
