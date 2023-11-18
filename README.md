# ecs-swift

A description of this package.

## 注意書き Warning

私はこのパッケージの更新をあまり積極的に行っていません。本当にごめんなさい。特に、私は個人で 2D ゲームを制作することに注力していることもあり、3D ゲームに対するサポートは希薄となっています。またそのような背景から、積極的に新しい機能を迅速に取り入れることは稀だと認識してください。

しかし、全く更新しないというわけではなく、必要に応じてメンテナンスし、機能も追加し、リファクタリングし、デバッグしていく予定です（ゆっくりかもしれません）。意見・要望などがあればぜひ、 [Discussions](https://github.com/rrbox/ecs-swift/discussions) へ！

このツールの開発者 [rrbox](https://github.com/rrbox) より

## Examples

```swift
import ECS
```

### Create Component

```swift
struct Position: Component {
    var x: CGFloat
    var y: CGFlaot
}
```

### Create System

```swift
func moveableEntitySpawnSystem(commands: Commands) {
    commands.spawn()
        .addComponent(Position(x: 50, y: 100))
}

func movementSystem(query: Query<Position>, deltaTime: Resource<DeltaTime>) {
    query.update { position, deltaTime in
        position.value.x += 120 * deltaTime.resource
    }
}

func printPositionSystem(query: Query<Position>) {
    query.update { position in
        print(position.value)
    }
}

```

### Create World

```swift
let world = World()
    .addSystem(.startUp, moveableEntitySpawnSystem(commands:))
    .addSystem(.update, movementSystem(query:deltaTime:))
    .addSystem(.update, printPositionSystem(query:))
```

### Run World (SpriteKit)

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

詳しい解説は Wiki にて！

## ライセンス契約

以下に基づいてライセンスされています。

- MIT license

「Warning」でも述べたように、制作者はパッケージ更新にあまり着手できていません。もし更新を待ちきれない場合、あるいは制作者の方針から外れた実装を求める場合、「あなたの `ecs-swift`」へと改造する選択肢も忘れないでください。
