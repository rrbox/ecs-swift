#  Events

Event の発信・受信を system 内から行うことができます.

イベントとして発信する値の型を定義します.

```swift
struct EventType: EventProtocol {}
```

イベントを受け取る/発信するシステムを定義します.

```swift
func eventPostSystem(eventWriter: EventWriter<EventType>) {
    eventWriter.send(EventType0()) // event post
}

func eventGetSystem(eventReader: EventReader<EventType>) {
    let event = eventReader.value // event get
}
```

イベントに関連するシステムを ``World`` に追加します.

```swift
let world = World()
    .addEventStreamer(EventType.self)
    .addSystem(.update, eventPostSystem(eventWriter:))
    .buildEventResponder { responder in
        responder.addSystem(.update, eventGetSystem(eventReader:))
    }
}
```

@Links(visualStyle: list) {
    - ``EventProtocol``
    - ``EventWriter``
    - ``EventReader``
}

- note: ``World`` の外部からイベントを受け渡したい場合は, ``World/sendEvent(_:)`` を使用してください.
