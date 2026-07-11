//
//  Test.swift
//  ECS_Swift
//
//  Created by rrbox on 2025/03/16.
//

import ECS
import Testing

struct Test {
    enum StateCase: StateProtocol {
        case title
        case inGame
    }

    // タスク 7.2: 各テストは新旧両バックエンド(WorldBackend.allCases)で実行されます。
    @MainActor
    @Test(arguments: WorldBackend.allCases)
    func startUpSystems(backend: WorldBackend) async throws {
        var flags = [0, 0, 0, 0, 0, 0]
        let world = backend.makeWorld()
            .addSystem(.preStartUp) { (_: Commands) in // 1
                flags[0] += 1
                #expect(flags == [1, 0, 0, 0, 0, 0])
            }
            .addSystem(.startUp) { (_: Commands) in // 2
                flags[1] += 1
                #expect(flags == [1, 1, 0, 0, 0, 0])
            }
            .addSystem(.postStartUp) { (_: Commands) in // 3
                flags[2] += 1
                #expect(flags == [1, 1, 1, 0, 0, 0])
            }
            .addSystem(.preUpdate) { (_: Commands) in // 4
                flags[3] += 1
                #expect(flags == [1, 1, 1, 1, 0, 0])
            }
            .addSystem(.update) { (_: Commands) in // 5
                flags[4] += 1
                #expect(flags == [1, 1, 1, 1, 1, 0])
            }
            .addSystem(.postUpdate) { (_: Commands) in // 6
                flags[5] += 1
                #expect(flags == [1, 1, 1, 1, 1, 1])
            }

        world.setUpWorld()

        world.update(currentTime: -1)
        world.update(currentTime: 0)

        #expect(flags == [1, 1, 1, 1, 1, 1])
    }

    @MainActor
    @Test(arguments: WorldBackend.allCases)
    func stateDidEnter(backend: WorldBackend) async throws {
        var flags = [0, 0, 0, 0]
        let world = backend.makeWorld()
            .addState(initialState: StateCase.title, states: [.title, .inGame])
            .addSystem(.didEnter(StateCase.title), { (_ :Commands) in // 2
                flags[1] += 1
                #expect(flags == [1, 1, 0, 0])
            })
            .addSystem(.preStartUp) { (_: Commands) in // 1
                flags[0] += 1
                #expect(flags == [1, 0, 0, 0])
            }
            .addSystem(.startUp) { (_: Commands) in // 3
                flags[2] += 1
                #expect(flags == [1, 1, 1, 0])
            }
            .addSystem(.postStartUp) { (_: Commands) in // 4
                flags[3] += 1
                #expect(flags == [1, 1, 1, 1])
            }

        world.setUpWorld()

        world.update(currentTime: -1)

        #expect(flags == [1, 1, 1, 1])
    }

}
