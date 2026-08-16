#  Add system into World

``World`` を稼働する前に, システムを登録します.

## Overview

``World`` には最大5つのパラメータをもつ関数をシステムとして登録できます.

```swift
let world = World()
    .addSystem(.startUp, startUpSystem(commands:))
    .addSystem(.update, gameSystem(query:commands))
```

システムの登録は ``World/setUpWorld()`` を実行するまでに完了させてください.
稼働中の ``World`` にシステムを追加することはできません
(``World/setUpWorld()`` 以降の `addSystem` は実行時エラーになります).

これは, システムの登録に伴って追加される ``Query`` に, 登録より前に spawn された entity が反映されないためです.
状況に応じてシステム構成を切り替える場合は, <doc:States> を使用してください.

- ``World/addSystem(_:_:)-9frsg``
- ``World/addSystem(_:_:)-86ff2``
- ``World/addSystem(_:_:)-7kznt``
- ``World/addSystem(_:_:)-1s1oy``
- ``World/addSystem(_:_:)-4jv38``
