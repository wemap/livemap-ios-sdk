#
#  Be sure to run `pod spec lint livemap-ios-sdk.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "livemap-ios-sdk"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of livemap-ios-sdk."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  Description is here.
                   DESC

  spec.homepage     = "http://EXAMPLE/livemap-ios-sdk"
  spec.license      = "MIT"
  spec.author             = { "Thibault Capelli" => "capellithibault@gmail.com" }
  spec.source       = { :git => "https://github.com/wemap/livemap-ios-sdk.git", :tag => "#{spec.version}" }

  spec.ios.deployment_target = '10.0'

  spec.source_files  = "livemap-ios-sdk/**/*.{swift}", "CustomARView.{swift}", "Libraries/**/*.{modulemap,swift}"
  spec.resources = ["**/*.{xib, png, jpeg, jpg}"]

  spec.xcconfig = { 
    'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/Libraries',
    # 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/NAOSDK/Pod/Classes'
  }

  spec.frameworks = 'UIKit', 'CoreGraphics'

  spec.static_framework = true
  spec.libraries = "c++", "z", "NAOSDK"
  spec.frameworks  = "CoreBluetooth", "CoreLocation", "CoreMotion", "SystemConfiguration"
  spec.requires_arc = true

  spec.dependency "NAOSDK"

end
