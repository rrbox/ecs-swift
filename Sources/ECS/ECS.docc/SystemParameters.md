#  System parameters

## Overview

システムとして関数を定義した場合, 引数を介して ``World`` からゲームをコントロールするオブジェクトを受け取ることができます.

```swift
func system(param: <#ParameterType#>) {
    
}
```

`ecs-swift` ではシステムひとつにつき, 最大5つまで system parameter を指定できます.

```swift
func system(param_0: <#ParameterType0#>,
            param_1: <#ParameterType1#>,
            param_2: <#ParameterType2#>,
            param_3: <#ParameterType3#>,
            param_4: <#ParameterType4#>) {
    
}
```

### Topics

@Links(visualStyle: detailedGrid) {
    - <doc:Queries>
    - ``Commands``
    - ``Resource``
    - ``State``
    - <doc:ParametersForEvent>
}
