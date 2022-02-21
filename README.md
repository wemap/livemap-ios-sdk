# To combine silumator and device frameworks

Il ne faut surtout pas utiliser lipo ou fat frameworks qui sont deprected et non supportés par Apple.

Voici la doc Apple:
https://developer.apple.com/videos/play/wwdc2019/416/
voir slide 93 ici avec la commande avec deux frameworks comme dans le script
https://devstreaming-cdn.apple.com/videos/wwdc/2019/416h8485aty341c2/416/416_binary_frameworks_in_swift.pdf?dl=1

find . -name "*.framework"
./xcframework/livemap_ios_sdk.xcframework/ios-arm64_i386_x86_64-simulator/livemap_ios_sdk.framework
./xcframework/livemap_ios_sdk.xcframework/ios-arm64_armv7/livemap_ios_sdk.framework

Pour combiner les deux.
mkdir ./releases/v1.6.0
xcodebuild -create-xcframework -framework ./xcframework/livemap_ios_sdk.xcframework/ios-arm64_i386_x86_64-simulator/livemap_ios_sdk.framework -framework ./xcframework/livemap_ios_sdk.xcframework/ios-arm64_armv7/livemap_ios_sdk.framework -output ./releases/v1.6.0/livemap_ios_sdk.xcframework

Il faut le zipper puis le commiter.
brew update
brew install p7zip

7z a ./releases/v1.6.0/livemap_ios_sdk.xcframework.zip ./xcframework/livemap_ios_sdk.xcframework
dangerous command!!
rm -rf ./releases/v1.6.0/livemap_ios_sdk.xcframework
