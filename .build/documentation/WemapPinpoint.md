# WemapPinpoint

Create a Wemap Pinpoint

``` swift
public class WemapPinpoint: NSObject
```

## Inheritance

`NSObject`

## Initializers

### `init(_:)`

``` swift
public init(_ json: NSDictionary)
```

#### Parameters

  - json: { id, longitude, latitude, name, description, external\_data }

## Properties

### `id`

``` swift
let id: Int
```

### `longitude`

``` swift
let longitude: Double
```

### `latitude`

``` swift
let latitude: Double
```

### `name`

``` swift
let name: String
```

### `pinpointDescription`

``` swift
let pinpointDescription: String
```

### `external_data`

``` swift
let external_data: NSDictionary?
```
