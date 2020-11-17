# WemapSDKMapActionsDelegate

WemapSDKMapDelegate used to pass notifictons about user actions on map.
All notifications will be sent in background queue and this is optional to implement handling all of them.

``` swift
@objc public protocol WemapSDKMapActionsDelegate: class
```

## Inheritance

`class`

## Optional Requirements

### regionDidChanged(controller:​)

Notify user moved map to specified region.

``` swift
@objc optional func regionDidChanged(controller: wemapsdk)
```

#### Parameters

  - region: an WemapSDKMapBaseViewController object of map view controller. Could be sublassed to WemapSDKMapViewController or WemapSDKMapKitViewController, depends on type of map which you used.

### openPinpoint(controller:​)

Notify user moved map to specified region.

``` swift
@objc optional func openPinpoint(controller: wemapsdk)
```

#### Parameters

  - controller: an WemapSDKMapBaseViewController object of map view controller. Could be sublassed to WemapSDKMapViewController or WemapSDKMapKitViewController, depends on type of map which you used.
  - pinpoint: a touched WemapPinpoint object.

### openList(controller:​)

Notify user moved map to specified region.

``` swift
@objc optional func openList(controller: wemapsdk)
```

#### Parameters

  - controller: an WemapSDKMapBaseViewController object of map view controller. Could be sublassed to WemapSDKMapViewController or WemapSDKMapKitViewController, depends on type of map which you used.
  - list: an opened WemapList object.

### bookEvent(controller:​)

Notify user booked event or event added to user calendar.

``` swift
@objc optional func bookEvent(controller: wemapsdk)
```

#### Parameters

  - controller: an WemapSDKMapBaseViewController object of map view controller. Could be sublassed to WemapSDKMapViewController or WemapSDKMapKitViewController, depends on type of map which you used.
  - event: a WemapEvent object.

### sharePinpoint(controller:​)

Notify user moved map to specified region.

``` swift
@objc optional func sharePinpoint(controller: wemapsdk)
```

#### Parameters

  - controller: an WemapSDKMapBaseViewController object of map view controller. Could be sublassed to WemapSDKMapViewController or WemapSDKMapKitViewController, depends on type of map which you used.
  - pinpoint: a shared WemapPinpoint object.

### shareMap(controller:​)

Notify user moved map to specified region.

``` swift
@objc optional func shareMap(controller: wemapsdk)
```

#### Parameters

  - controller: an WemapSDKMapBaseViewController object of map view controller. Could be sublassed to WemapSDKMapViewController or WemapSDKMapKitViewController, depends on type of map which you used.
  - map: an touched WemapPinpoint object.
