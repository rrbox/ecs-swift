#  Resources

World 内に単一のインスタンスを作ります.

Resource を ``ResourceProtocol`` により定義します.

```swift
struct Counter: ResourceProtocol {
    var value: Int
}
```

`Counter` を扱うシステムを定義します.

```swift
func increment(counter: Resource<Counter>) {
    counter.resource += 1
}

func printCounter(counter: Resource<Counter>) {
    print(counter.resource)
}
```

``World`` インスタンスに `Counter` リソースと`increment(counter:)`を登録します.

```swift
let world = World()
    .addResource(Counter(0))
    .addSystem(.update, increment(counter:))
    .addSystem(.update, printCounter(counter:))
```

- ``ResourceProtocol``
- ``Resource``
