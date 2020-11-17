# WemapEvent

Create a Wemap Event

``` swift
public class WemapEvent: NSObject
```

## Inheritance

`NSObject`

## Initializers

### `init(_:)`

``` swift
public init(_ json: NSDictionary)
```

#### Parameters

  - json: { id, name, description, external\_data }

## Properties

### `id`

``` swift
let id: Int
```

### `name`

``` swift
let name: String
```

### `eventDescription`

``` swift
let eventDescription: String
```

### `pinpoint`

``` swift
let pinpoint: WemapPinpoint?
```

### `external_data`

``` swift
let external_data: NSDictionary?
```
