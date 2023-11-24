#  Queries

コンポーネントを取得・更新します.

## Overview

システムは Query を介して, ``World`` に生成された ``Entity`` に紐づいた ``Component`` を操作することができます.

```swift
func system(query: Query<ComponentType>) {
    query.update { _, component in
        // component update
    }
}
```

@Links(visualStyle: list) {
    - ``Query``
    - ``Query2``
    - ``Query3``
    - ``Query4``
    - ``Query5``
}

