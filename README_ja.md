# ecs-swift

[![GitHub issues](https://img.shields.io/github/issues/rrbox/ecs-swift)](https://github.com/rrbox/ecs-swift/issues)
[![GitHub License](https://img.shields.io/github/license/rrbox/ecs-swift)](https://github.com/rrbox/ecs-swift/blob/main/LICENSE)
[![Swift](https://github.com/rrbox/ecs-swift/actions/workflows/swift.yml/badge.svg?branch=release%2Flatest)](https://github.com/rrbox/ecs-swift/actions/workflows/swift.yml)

`ecs-swift` は、Swift で Entity Component System (ECS) を実装したライブラリです。SpriteKit や SceneKit などのフレームワークで ECS 設計のゲームを開発するために使用します。

これは Rust の ECS クレートである Bevy ECS から多大なる影響を受けています！とくにecs-swiftは protocol 指向を意識して設計されており、**コンポーネントを構造体で定義**することができます！

ただし制作者本人は、Bevy ECS の完全コピーではなく、Swift で作った**劣化版**だと認識しています。詳しくは、Wiki の Bevy ECS の劣化版としての ecs-swift （準備中）を参照してください。

## 注意書き Warning

私はこのパッケージの更新をあまり積極的に行っていません。本当にごめんなさい。特に、私は個人で 2D ゲームを制作することに注力していることもあり、3D ゲームに対するサポートは希薄となっています。またそのような背景から、積極的に新しい機能を迅速に取り入れることは稀だと認識してください。

しかし、全く更新しないというわけではなく、必要に応じてメンテナンスし、機能も追加し、リファクタリングし、デバッグしていく予定です（ゆっくりかもしれません）。意見・要望などがあればぜひ、 [Discussions](https://github.com/rrbox/ecs-swift/discussions) へ！

このツールの開発者 [rrbox](https://github.com/rrbox) より

## Getting Started

### Requirements

- Xcode 14.3 
- Swift 5.9

### Swift Package Manager

```swift
// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "Your project",
  dependencies: [
    .package(url: "https://github.com/rrbox/ecs-swift.git", from: "0.1.0")
  ],
  targets: [
    .target(name: "Your project", dependencies: ["ECS", "PlugIns"])
  ]
)
```

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

詳しい解説は Wiki （準備中）にて！

## ライセンス契約

以下に基づいてライセンスされています。

- MIT license

「Warning」でも述べたように、制作者はパッケージ更新にあまり着手できていません。もし更新を待ちきれない場合、あるいは制作者の方針から外れた実装を求める場合、「あなたの `ecs-swift`」へと改造する選択肢も忘れないでください。
