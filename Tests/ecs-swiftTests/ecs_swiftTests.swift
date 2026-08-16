import XCTest
@testable import ECS

struct Text: Component {
    let v: String
}

func entitycreate(commands: Commands) {
    for i in 1...20000 {
        commands.spawn()
            .addComponent(Text(v: "\(i)"))
    }
}

func entitycreate2(commands: Commands) {
    for i in 1...20000 {
        commands.spawn()
            .addComponent(Text(v: "\(i)"))
    }
}


func update(query: Query<Text>) {
    query.update { _ in

    }
}

func update2(query: Query<Text>) {
    query.update { _ in

    }
}

func update3(query: Query<Text>) {
    query.update { _ in

    }
}

func update4(query: Query<Text>) {
    query.update { _ in

    }
}

final class ecs_swiftTests: XCTestCase {
    // タスク 7.2: `measure` はテストメソッドごとに 1 回しか呼べないため、
    // ループではなくバックエンドごとのテストメソッドで新旧両方を実行します。

    private func runPerformance(backend: WorldBackend) {
        let world = backend.makeWorld()
            .addSystem(.startUp, entitycreate(commands:))
            .addSystem(.update, update(query:))
        world.setUpWorld()
        world.update(currentTime: -1)

        print(world.entities.data.count)

        measure {
            world.update(currentTime: 0)
        }
    }

    private func runUpdate4Performance(backend: WorldBackend) {
        let world = backend.makeWorld()
            .addSystem(.startUp, entitycreate(commands:))
            .addSystem(.update, update(query:))
            .addSystem(.update, update2(query:))
            .addSystem(.update, update3(query:))
            .addSystem(.update, update4(query:))
        world.setUpWorld()
        world.update(currentTime: -1)

        print(world.entities.data.count)

        measure {
            world.update(currentTime: 0)
        }
    }

    // entity: 20000
    // set up: 1
    // update: 1
    // 0.00478 s
    func testPerformance() {
        self.runPerformance(backend: .legacy)
    }

    func testPerformanceArchetype() {
        self.runPerformance(backend: .archetype)
    }

    // entity: 20000
    // set up: 1
    // update: 4
    // 0.0158 s -> およそ 4 倍
    func testUpdate4Performance() {
        self.runUpdate4Performance(backend: .legacy)
    }

    func testUpdate4PerformanceArchetype() {
        self.runUpdate4Performance(backend: .archetype)
    }
}
