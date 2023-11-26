#  Add system into World

``World`` を稼働する前に, システムを登録します.

## Overview

``World`` には最大5つのパラメータをもつ関数をシステムとして登録できます.

```swift
let world = World()
    .addSystem(.startUp, startUpSystem(commands:))
    .addSystem(.update, gameSystem(query:commands))
```

- ``World/addSystem(_:_:)-9frsg``
- ``World/addSystem(_:_:)-86ff2``
- ``World/addSystem(_:_:)-7kznt``
- ``World/addSystem(_:_:)-1s1oy``
- ``World/addSystem(_:_:)-4jv38``
