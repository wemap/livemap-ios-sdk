# wemapsdk

``` swift
public class wemapsdk: UIView, WKUIDelegate
```

## Inheritance

`UIView`, `WKNavigationDelegate`, `WKScriptMessageHandler`, `WKUIDelegate`

## Initializers

### `init?(coder:)`

``` swift
public required init?(coder aDecoder: NSCoder)
```

## Properties

### `sharedInstance`

``` swift
let sharedInstance
```

### `delegate`

``` swift
var delegate: wemapsdkViewDelegate?
```

## Methods

### `layoutSubviews()`

``` swift
public override func layoutSubviews()
```

### `webView(_:didFinish:)`

``` swift
open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
```

### `webView(_:didFail:withError:)`

``` swift
open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
```

### `configure(config:)`

``` swift
public func configure(config: wemapsdk_config) -> wemapsdk
```

### `presentIn(view:)`

``` swift
public func presentIn(view: UIView) -> wemapsdk
```

### `userContentController(_:didReceive:)`

``` swift
public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
```

### `waitForReady()`

``` swift
public func waitForReady()
```

### `openEvent(WemapEventId:)`

Open an event on the map. This can only be used for maps which use events.

``` swift
public func openEvent(WemapEventId id: Int)
```

#### Parameters

  - id: event id

### `closeEvent()`

Close the current opened event. Go to the search view.

``` swift
public func closeEvent()
```

### `openPinpoint(WemapPinpointId:)`

Open a pinpoint on the map.

``` swift
public func openPinpoint(WemapPinpointId id: Int)
```

#### Parameters

  - id: id of the pinpoint to open

### `closePinpoint()`

Close the current opened pinpoint. Go to the search view.

``` swift
public func closePinpoint()
```

### `setFilters(WemapFilters:)`

Update search filters (dates, tags, text).

``` swift
public func setFilters(WemapFilters: WemapFilters)
```

#### Parameters

  - WemapFilters: Filters to set. See [WemapFilters](./structs/WemapFilters.md "structure WemapLocation").

### `navigateToPinpoint(WemapPinpointId:location:heading:)`

Start navigation to a pinpoint. The navigation will start with the user location.

``` swift
public func navigateToPinpoint(WemapPinpointId id: Int, location: WemapLocation? = nil, heading: Int? = nil)
```

#### Parameters

  - id: Id of the destination pinpoint.
  - location: For relative navigation only. Navigation start location. See [WemapLocation](./classes/WemapLocation.md "structure WemapLocation").
  - heading: For relative navigation only. Navigation start heading (in degrees).

### `stopNavigation()`

Stop the currently running navigation.

``` swift
public func stopNavigation()
```
