# WemapFilters

Create a map filter

``` swift
public struct WemapFilters: Codable
```

## Inheritance

`Codable`

## Initializers

### `init(tags:query:startDate:endDate:)`

``` swift
public init(tags: Array<String>? = nil, query: String? = nil, startDate: String? = nil, endDate: String? = nil)
```

#### Parameters

  - tags: The queried tags
  - query: The queried keywords
  - startDate: The start date as yyyy-mm-dd
  - endDate: The end date as yyyy-mm-dd
