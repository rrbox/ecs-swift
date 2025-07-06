//
//  World+SetUp.swift
//  
//
//  Created by rrbox on 2023/08/12.
//

public extension World {
    func setUpWorld() {
        self.preUpdateSchedule = .preStartUp
        self.updateSchedule = .startUp
        self.postUpdateSchedule = .postStartUp
    }
}
