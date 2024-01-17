import XCTest

#if DEBUG
@testable import ECS
#else
import ECS
#endif

struct Text: Component {
    let v: String
}

func entitycreate(commands: Commands) async {
    for i in 1...20000 {
        await commands.spawn()
            .addComponent(Text(v: "\(i)"))
    }
}

func entitycreate2(commands: Commands) async {
    for i in 1...20000 {
        await commands.spawn()
            .addComponent(Text(v: "\(i)"))
    }
}


func update(query: Query<Text>) async {
    await query.update { _, _ in
        
    }
}

func update2(query: Query<Text>) async {
    await query.update { _, _ in
        
    }
}

func update3(query: Query<Text>) async {
    await query.update { _, _ in
        
    }
}

func update4(query: Query<Text>) async {
    await query.update { _, _ in
        
    }
}

final class ecs_swiftTests: XCTestCase {
    // entity: 20000
    // set up: 1
    // update: 1
    // 0.00478 s
    
    // 100 times update
    // 0.424 sec
    // 0.282 sec (release)
    func testPerformance() async {
        let world = await World()
            .addSystem(.startUp, entitycreate(commands:))
            .addSystem(.update, update(query:))
        await world.setUpWorld()
        
        #if DEBUG
        
        print(world.entities.sequence.count)
        
        #endif
        
        await world.update(currentTime: 0)
        
        measure {
            let exp = expectation(description: "Finished")
            Task {
                for i in 1...100 {
                    await world.update(currentTime: TimeInterval(i))
                }
                exp.fulfill()
            }
            wait(for: [exp], timeout: 200.0)
        }
        
    }
    
    // entity: 20000
    // set up: 1
    // update: 4
    // 0.0158 s -> およそ 4 倍
    
    // 100 times update
    // 1.713 sec
    // 1.139 sec (release)
    func testUpdate4Performance() async {
        let world = await World()
            .addSystem(.startUp, entitycreate(commands:))
            .addSystem(.update, update(query:))
            .addSystem(.update, update2(query:))
            .addSystem(.update, update3(query:))
            .addSystem(.update, update4(query:))
        
        await world.setUpWorld()
        
        #if DEBUG
        
        print(world.entities.sequence.count)
        
        #endif
        
        await world.update(currentTime: 0)
        
        measure {
            let exp = expectation(description: "Finished")
            Task {
                for i in 1...100 {
                    await world.update(currentTime: TimeInterval(i))
                }
                exp.fulfill()
            }
            wait(for: [exp], timeout: 200.0)
        }
        
    }
    
    // 0.286 sec (release)
    // 2.821 sec (release, 1000 systems)
    // 0.286 sec (contiguous array + release)
    // 2.849 sec (contiguous array + release, 1000 systems)
    func testLargeAmountSystemPerformance() async {
        assert(true)
        let world = await World().addSystem(.startUp, entitycreate(commands:))
        for _ in 0...1000 {
            await world.addSystem(.update, update(query:))
        }
        
        await world.setUpWorld()
        await world.update(currentTime: 0)
        
        measure {
            let exp = expectation(description: "Finished")
            Task {
                await world.update(currentTime: TimeInterval(0))
                exp.fulfill()
            }
            wait(for: [exp], timeout: 200.0)
        }
        
    }
}
