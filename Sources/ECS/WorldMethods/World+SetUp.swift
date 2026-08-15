//
//  World+SetUp.swift
//
//
//  Created by rrbox on 2023/08/12.
//

public extension World {
    /// World を起動し, システム構成を確定します.
    ///
    /// この関数の実行後に ``World/addSystem(_:_:)-9frsg`` を実行することはできません.
    func setUpWorld() {
        self.isSetUpCompleted = true
        self.preUpdateSchedule = .preStartUp
        self.updateSchedule = .startUp
        self.postUpdateSchedule = .postStartUp
    }
}

extension World {
    func preconditionSystemRegistrationIsAvailable() {
        precondition(
            !self.isSetUpCompleted,
            "addSystem is not supported after world setup is completed."
        )
    }
}
