//
//  RemovedOnInactiveScheduleTests.swift
//  ECS_Swift
//
//  Created by rrbox on 2026/08/16.
//

import Testing
@testable import ECS

private enum InactiveScheduleTestState: StateProtocol {
    case stateA
    case stateB
}

private final class RemovedOnInactiveBox {
    var entities: [Entity] = []
    var removedOnInactiveCount = 0
}

/// `.removedOnInactive` スケジュールの登録/解除についてのテストです.
struct RemovedOnInactiveScheduleTests {
    /// state が resume した後は `.removedOnInactive` スケジュールが解除されている必要があります.
    ///
    /// push によって inactive になった state の `.removedOnInactive` は
    /// `Removed` イベントで実行されますが, pop によって active に戻った後は
    /// 実行されてはいけません.
    @Test func removedOnInactiveScheduleStopsAfterPop() {
        let box = RemovedOnInactiveBox()
        let world = World()
            .addState(initialState: InactiveScheduleTestState.stateA, states: [.stateA, .stateB])
            .addSystem(.update) { (commands: Commands, state: State<InactiveScheduleTestState>, time: Resource<CurrentTime>) in
                switch time.resource.value {
                case 1:
                    // stateA が inactive になります.
                    state.push(.stateB)
                    box.entities.append(
                        commands.spawn()
                            .addComponent(TestComponent(content: "inactive"))
                            .id()
                    )
                case 2:
                    // Removed 発火 -> removedOnInactive(stateA) が実行されます.
                    commands.despawn(entity: box.entities[0])
                case 3:
                    // stateA が active に戻るため removedOnInactive(stateA) は解除されます.
                    state.pop()
                case 4:
                    box.entities.append(
                        commands.spawn()
                            .addComponent(TestComponent(content: "active"))
                            .id()
                    )
                case 5:
                    // Removed 発火. removedOnInactive(stateA) は実行されません.
                    commands.despawn(entity: box.entities[1])
                default:
                    break
                }
            }
            .addSystem(.removedOnInactive(InactiveScheduleTestState.stateA)) { (removed: Removed) in
                box.removedOnInactiveCount += 1
            }

        for frame in stride(from: 0.0, through: 6.0, by: 1.0) {
            world.update(currentTime: frame)
        }

        #expect(box.removedOnInactiveCount == 1)
    }
}
