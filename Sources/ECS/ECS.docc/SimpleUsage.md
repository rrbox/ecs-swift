#  Usage

簡単な使い方の解説です.

コンポーネントは構造体で定義できます.

```swift
struct Position: Component {
    var x: CGFloat
    var y: CGFlaot
}
```

関数で system を定義し,

```swift
func moveableEntitySpawnSystem(commands: Commands) {
    commands.spawn()
        .addComponent(Position(x: 50, y: 100))
}

func movementSystem(query: Query<Position>, deltaTime: Resource<DeltaTime>) {
    query.update { _, position, deltaTime in
        position.value.x += 120 * deltaTime.resource
    }
}

func presentPositionSystem(query: Query<Position>) {
    query.update { _, position in
        print(position.value)
    }
}
```

``World`` インスタンスに関数を導入します.

```swift
let world = World()
    .addSystem(.startUp, moveableEntitySpawnSystem(commands:))
    .addSystem(.update, movementSystem(query:deltaTime:))
    .addSystem(.update, presentPositionSystem(query:))
```

SpriteKit で動作させる場合は以下のように稼働させます:

```swift
import SpriteKit
import ECS

class Scene: SKScene {
    override func didMove(to view: SKView) {
        world.setUp()
    }
    
    override func update(_ currentTime: TimeInterval) {
        world.update(currentTime)
    }
}
```
