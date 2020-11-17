# wemapsdkViewDelegate

``` swift
@objc public protocol wemapsdkViewDelegate: AnyObject
```

## Inheritance

`AnyObject`

## Optional Requirements

### waitForReady(\_:​)

``` swift
@objc optional func waitForReady(_ wemapController: wemapsdk)
```

### onEventOpen(\_:​event:​)

``` swift
@objc optional func onEventOpen(_ wemapController: wemapsdk, event: WemapEvent)
```

### onPinpointOpen(\_:​pinpoint:​)

``` swift
@objc optional func onPinpointOpen(_ wemapController: wemapsdk, pinpoint: WemapPinpoint)
```

### onEventClose(\_:​)

``` swift
@objc optional func onEventClose(_ wemapController: wemapsdk)
```

### onPinpointClose(\_:​)

``` swift
@objc optional func onPinpointClose(_ wemapController: wemapsdk)
```

### onGuidingStarted(\_:​)

``` swift
@objc optional func onGuidingStarted(_ wemapController: wemapsdk)
```

### onGuidingStopped(\_:​)

``` swift
@objc optional func onGuidingStopped(_ wemapController: wemapsdk)
```

### onBookEventClicked(\_:​event:​)

``` swift
@objc optional func onBookEventClicked(_ wemapController: wemapsdk, event: WemapEvent)
```

### onGoToPinpointClicked(\_:​pinpoint:​)

``` swift
@objc optional func onGoToPinpointClicked(_ wemapController: wemapsdk, pinpoint: WemapPinpoint)
```
