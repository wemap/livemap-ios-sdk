### create fat-library
```
cp -r ../../Build/Products/Release-iphoneos/livemap_ios_sdk.framework ./livemap_ios_sdk.framework
cp -r ../../Build/Products/Release-iphonesimulator/livemap_ios_sdk.framework/Modules/livemap_ios_sdk.swiftmodule/* livemap_ios_sdk.framework/Modules/livemap_ios_sdk.swiftmodule

lipo -create ../../Build/Products/Release-iphoneos/livemap_ios_sdk.framework/livemap_ios_sdk ../../Build/Products/Release-iphonesimulator/livemap_ios_sdk.framework/livemap_ios_sdk -output lipo-livemap_ios_sdk

mv lipo-livemap_ios_sdk livemap_ios_sdk.framework/livemap_ios_sdk
lipo -info livemap_ios_sdk.framework/livemap_ios_sdk
```

### update Info.plist

`open livemap_ios_sdk.framework/Info.plist`

=> add `iPhoneSimulator` to CFBundleSupportedPlatforms

### deploy on s3

ex: https://ressources.getwemap.com/ios/v1.2.0/livemap_ios_sdk.framework.zip
