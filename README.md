# `ecs-swift`

[![GitHub issues](https://img.shields.io/github/issues/rrbox/ecs-swift)](https://github.com/rrbox/ecs-swift/issues)
[![GitHub License](https://img.shields.io/github/license/rrbox/ecs-swift)](https://github.com/rrbox/ecs-swift/blob/main/LICENSE)
[![Swift](https://github.com/rrbox/ecs-swift/actions/workflows/swift.yml/badge.svg?branch=release%2Flatest)](https://github.com/rrbox/ecs-swift/actions/workflows/swift.yml)

`ecs-swift` is a library that implements the Entity Component System (ECS) in Swift. It is used for developing games with ECS design in frameworks such as SpriteKit and SceneKit.

This library has been greatly influenced by the ECS library of Rust, the [Bevy ECS](https://github.com/bevyengine/bevy)! Particularly, `ecs-swift` is designed with a focus on protocol-oriented programming, allowing you to define components using **structures**!

However, the creator acknowledges that `ecs-swift` is not a complete copy of the Bevy ECS but rather a **lite version** created in Swift. For more details, please refer to the Wiki for `ecs-swift` as a lite version of the Bevy ECS.

:paperclip: [Japanese](README_ja.md)

## Warning

I believe I may not be able to actively update this package very often. I sincerely apologize for that. The reason behind this is my personal focus on creating 2D games. Please understand that incorporating new features promptly is rare for me. Additionally, due to this background, support for 3D games is limited.

However, it doesn't mean that I won't update it at all. I plan to maintain, add features, refactor, and debug as needed (though it might be at a slower pace). If you have any opinions or requests, please feel free to share them in the [Discussions](https://github.com/rrbox/ecs-swift/discussions) (under construction)!

From the developer of this tool, [@rrbox](https://github.com/rrbox).

## Getting started

### Requirements

- Xcode 14.3 
- Swift 5.8

### Swift package

```swift
// swift-tools-version:5.8

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

### Create World

```swift
let world = World()
    .addSystem(.startUp, moveableEntitySpawnSystem(commands:))
    .addSystem(.update, movementSystem(query:deltaTime:))
    .addSystem(.update, presentPositionSystem(query:))
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

Detailed explanations can be found in the [Wiki](https://github.com/rrbox/ecs-swift/wiki) (under construction)!


## License

This is licensed under the following:

- MIT License

As mentioned in the "Warning," it seems that the creator may not be actively working on package updates. If you cannot wait for updates or if you seek implementations outside the creator's direction, don't forget the option of modifying "this `ecs-swift`" into "your `ecs-swift`."

