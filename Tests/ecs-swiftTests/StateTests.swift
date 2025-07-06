//
//  StateTests.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/03/30.
//

import ECS
import Testing

struct StateTests {

    enum StateCase: StateProtocol {
        case title
        case inGame
        case pause
    }

    @Test func transitionState() async throws {
        var flags: [Int] = .init(repeating: 0, count: 6)

        let world = World()
            .addState(initialState: StateCase.title, states: [.title, .inGame, .pause])
            .addSystem(.didEnter(StateCase.title)) { (currentTime: Resource<CurrentTime>) in
                flags[0] += 1
                #expect(flags == [1, 0, 0, 0, 0, 0])
                #expect(currentTime.resource.value == -1)
            }
            .addSystem(.onUpdate(StateCase.title)) { (currentTime: Resource<CurrentTime>,
                                                      state: State<StateCase>) in
                flags[1] += 1
                #expect(flags == [1, 1, 0, 0, 0, 0])
                #expect(currentTime.resource.value == -1)
                state.enter(.inGame)
            }
            .addSystem(.willExit(StateCase.title), { (currentTime: Resource<CurrentTime>) in
                flags[2] += 1
                #expect(flags == [1, 1, 1, 0, 0, 0])
                #expect(currentTime.resource.value == 0)
            })
            .addSystem(.didEnter(StateCase.inGame)) { (currentTime: Resource<CurrentTime>) in
                flags[3] += 1
                #expect(flags == [1, 1, 1, 1, 0, 0])
                #expect(currentTime.resource.value == 0)
            }
            .addSystem(.onUpdate(StateCase.inGame)) { (currentTime: Resource<CurrentTime>) in
                flags[4] += 1
                #expect(flags == [1, 1, 1, 1, 1, 1])
                #expect(currentTime.resource.value == 0)
            }
            .addSystem(.update) { (currentTime: Resource<CurrentTime>) in
                flags[5] += 1
                #expect(currentTime.resource.value == 0)
            }

        // didEnter title, on update title
        world.update(currentTime: -1)

        // will exit title, did enter inGame, on update inGame
        world.update(currentTime: 0)

        #expect(flags == [1, 1, 1, 1, 1, 1])
    }

    // case 1: `push` in start up
    @Test func pushStateInStartUp() async throws {
        var flags = [Int](repeating: 0, count: 6)

        let world = World()
            .addState(initialState: StateCase.inGame, states: [.inGame, .pause])
            .addSystem(.onStackUpdate(StateCase.inGame)) { (currentTime: Resource<CurrentTime>) in
                flags[0] += 1

                if flags == [0, 0, 0, 0, 0, 0] {
                    #expect(currentTime.resource.value == 0)
                }
            }
            .addSystem(.startUp, { (state: State<StateCase>,
                                    currentTime: Resource<CurrentTime>) in
                state.push(.pause)
                #expect(currentTime.resource.value == -1)
            })
            .addSystem(.onPause(StateCase.inGame)) { (currentTime: Resource<CurrentTime>) in
                flags[1] += 1
                #expect(flags == [1, 1, 0, 0, 0, 0])
                #expect(currentTime.resource.value == 0)
            }
            .addSystem(.didEnter(StateCase.pause)) { (currentTime: Resource<CurrentTime>) in
                flags[2] += 1
                #expect(flags == [1, 1, 1, 0, 0, 0])
                #expect(currentTime.resource.value == 0)
            }
            .addSystem(.onStackUpdate(StateCase.pause)) { (currentTime: Resource<CurrentTime>) in
                flags[3] += 1
                #expect(currentTime.resource.value == 0)
            }
            .addSystem(.onUpdate(StateCase.pause)) { (currentTime: Resource<CurrentTime>) in
                flags[4] += 1
                #expect(currentTime.resource.value == 0)
            }
            .addSystem(.onInactiveUpdate(StateCase.inGame)) { (currentTime: Resource<CurrentTime>) in
                flags[5] += 1
                #expect(currentTime.resource.value == 0)
            }

        // didEnter inGame, update inGame, onStackUpdate inGame
        world.update(currentTime: -1)

        // onPause inGame, didEnter pause, [onStackUpdate inGame, onStackUpdate pause, onUpdate pause, onInactiveUpdate inGame]
        world.update(currentTime: 0)

        #expect(flags == [2, 1, 1, 1, 1, 1])
    }

    // case 2: push in `update`
    @Test func pushStateInUpdate() async throws {
        var flags = [Int](repeating: 0, count: 6)

        let world = World()
            .addState(initialState: StateCase.inGame, states: [.inGame, .pause])
            .addSystem(.onStackUpdate(StateCase.inGame)) { (currentTime: Resource<CurrentTime>) in
                flags[0] += 1
            }
            .addSystem(.update, { (state: State<StateCase>,
                                    currentTime: Resource<CurrentTime>) in
                if currentTime.resource.value == 0 {
                    state.push(.pause)
                }
            })
            .addSystem(.onPause(StateCase.inGame)) { (currentTime: Resource<CurrentTime>) in
                flags[1] += 1
                #expect(flags == [2, 1, 0, 0, 0, 0])
                #expect(currentTime.resource.value == 1)
            }
            .addSystem(.didEnter(StateCase.pause)) { (currentTime: Resource<CurrentTime>) in
                flags[2] += 1
                #expect(flags == [2, 1, 1, 0, 0, 0])
                #expect(currentTime.resource.value == 1)
            }
            .addSystem(.onStackUpdate(StateCase.pause)) { (currentTime: Resource<CurrentTime>) in
                flags[3] += 1
                #expect(currentTime.resource.value == 1)
            }
            .addSystem(.onUpdate(StateCase.pause)) { (currentTime: Resource<CurrentTime>) in
                flags[4] += 1
                #expect(currentTime.resource.value == 1)
            }
            .addSystem(.onInactiveUpdate(StateCase.inGame)) { (currentTime: Resource<CurrentTime>) in
                flags[5] += 1
                #expect(currentTime.resource.value == 1)
            }

        // didEnter inGame, update inGame, onStackUpdate inGame
        world.update(currentTime: -1)

        // push pause, update inGame, onStackUpdate inGame
        world.update(currentTime: 0)

        // onPause inGame, didEnter pause, [onStackUpdate inGame, onStackUpdate pause, onUpdate pause, onInactiveUpdate inGame]
        world.update(currentTime: 1)

        #expect(flags == [3, 1, 1, 1, 1, 1])
    }

    // case 3: pop in `update`
    //
    // - start up で pop するケースは存在しない.
    @Test func popStateInUpdate() async throws {
        var flags = [Int](repeating: 0, count: 2)

        let world = World()
            .addState(initialState: StateCase.inGame, states: [.inGame, .pause])
            .addSystem(.startUp, { (state: State<StateCase>,
                                    currentTime: Resource<CurrentTime>) in
                state.push(.pause)
                #expect(currentTime.resource.value == -1)
            })
            .addSystem(.update) { (state: State<StateCase>, currentTime: Resource<CurrentTime>) in
                if currentTime.resource.value == 0 {
                    state.pop()
                }
            }
            .addSystem(.willExit(StateCase.pause)) { (currentTime: Resource<CurrentTime>) in
                flags[0] += 1
                #expect(flags == [1, 0])
                #expect(currentTime.resource.value == 1)
            }
            .addSystem(.onResume(StateCase.inGame)) { (currentTime: Resource<CurrentTime>) in
                flags[1] += 1
                #expect(flags == [1, 1])
                #expect(currentTime.resource.value == 1)
            }

        // didEnter inGame, update inGame, onStackUpdate inGame, push pause
        world.update(currentTime: -1)

        // onPause inGame, didEnter pause, [onStackUpdate inGame, onStackUpdate pause, onUpdate pause, onInactiveUpdate inGame], pop pause
        world.update(currentTime: 0)

        // onResume inGame, willExit pause
        world.update(currentTime: 1)

        #expect(flags == [1, 1])
    }
}
