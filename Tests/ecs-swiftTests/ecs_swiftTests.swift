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
    query.update { _, _ in
        
    }
}

func update2(query: Query<Text>) {
    query.update { _, _ in
        
    }
}

func update3(query: Query<Text>) {
    query.update { _, _ in
        
    }
}

func update4(query: Query<Text>) {
    query.update { _, _ in
        
    }
}

final class ecs_swiftTests: XCTestCase {
    // entity: 20000
    // set up: 1
    // update: 1
    // 0.00478 s
    func testPerformance() {
        let world = World()
            .addSetUpSystem(entitycreate(commands:))
            .addUpdateSystem(update(query:))
        world.setUpWorld()
        
        print(world.entities.sequence.count)
        
        measure {
            world.update(currentTime: 0)
        }
    }
    
    // entity: 20000
    // set up: 1
    // update: 4
    // 0.0158 s -> およそ 4 倍
    func testUpdate4Performance() {
        let world = World()
            .addSetUpSystem(entitycreate(commands:))
            .addUpdateSystem(update(query:))
            .addUpdateSystem(update2(query:))
            .addUpdateSystem(update3(query:))
            .addUpdateSystem(update4(query:))
        world.setUpWorld()
        
        print(world.entities.sequence.count)
        
        measure {
            world.update(currentTime: 0)
        }
    }
}
