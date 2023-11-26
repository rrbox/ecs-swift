#  Filtered query

条件を満たす entity のみを受け取ることができます.

```swift
struct Name: Component {
    let value: String
}

struct Age: Component {
    var value: Int
}


func createEntities(commands: Commands) {
    commands.spawn().addComponent(Name("Tom"))
    
    commands.spawn().addComponent(Age(0))
    
    commands.spawn().addComponent(Name("Bob")).addComponent(Age(10))
    
}

func name(query: Query<Name>) {
    query.update { _, name in
        print(name)
    }
    // "Tom"
    // "Bob"
}

func nameAndAge(query: Query2<Name, Age>) {
    qeury.update { _, name, age in
       print(name, age)
    }
    // "Bob", 10
}

func nameOnly(query: Filtered<Query<Name>, WithOut<Age>>) {
    query.update { _, name in
        print(name)
    }
    // "Tom"
}


func ageOnly(query: : Filtered<Query<Age>, With<Name>>) {
    query.update { _, age in
        print(age)
    }
    // 10
}

```

- note: Query については <doc:Queries> を参照してください.

@Links(visualStyle: list) {
    - ``Filtered``
    - ``With``
    - ``WithOut``
    - ``And``
    - ``Or``
}
