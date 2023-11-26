#  States

ゲーム内の状態管理を行います. State をスタックさせることでメニュー表示/非表示のような状態管理もできます.

## Overview

### World creation

State を以下のように定義します.

```swift
enum GameState: StateProtocol {
    case game, pause, gameOver
}
```

システムから状態管理を行う場合, ``State`` を利用します.

```swift
func manageState(state: State<GameState>) {
    state.enter(.gameOver) // ゲームオーバーへ遷移します.
    state.push(.pause) // ポーズ画面へ遷移します.
    state.pop() // (状態がスタックされている場合) 1つ前の状態に戻ります.
}
```

`world` に ``World/addState(initialState:states:)`` で管理下におきたい state を宣言します.

システムを追加するときに, ``Schedule/didEnter(_:)``, ``Schedule/willExit(_:)`` を指定することで状態遷移時に実行することを宣言します. 同様に ``Schedule/onPause(_:)``, ``Schedule/onResume(_:)`` を指定することでスタック時にシステムを実行することを宣言します. ``Schedule/onUpdate(_:)``, ``Schedule/onInactiveUpdate(_:)``, ``Schedule/onStackUpdate(_:)`` を指定することで, 各状態の有効/無効に従ってシステムを実行することを宣言します.

```swift
let world = World()
    .addState(initialState: GameState.game, states: [.game, .pause, .gameOver])
    .addSystem(.onUpdate(GameState.game), gameSystem)
    .addSystem(.onUpdate(GameState.gameOver), gameOverSystem)
    .addSystem(.onUpdate(GameState.pause), inPauseSystem)
    .addSystem(.onPause(GameState.game), pauseStart)
    .addSystem(.onResume(Game.game), resumeGame)
```

### Enter/Exit (State transition)

- ``State/enter(_:)``

### Push/Pop (State stack)

- ``State/push(_:)``
- ``State/pop()``
