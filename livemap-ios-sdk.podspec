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
  spec.version      = "2.7.0"
  spec.summary      = "The Wemap IOS SDK."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  The Wemap IOS SDK is a library that will handle communication with the Wemap application.
                   DESC

  spec.homepage     = "https://github.com/wemap/livemap-ios-sdk"
  spec.license      = "MIT"
  spec.author       = { "Thibault Capelli" => "thibault.capelli@getwemap.com" }
  spec.source       = { :git => "https://github.com/wemap/livemap-ios-sdk.git", :tag => "#{spec.version}" }

  spec.ios.deployment_target = '10.0'

  spec.static_framework = true

  spec.source_files  = "livemap-ios-sdk/**/*.{swift}", "CustomARView.{swift}"
  spec.resources = ["**/*.{xib, png, jpeg, jpg}"]

  spec.xcconfig = { 
    "FRAMEWORK_SEARCH_PATHS" => "$(PODS_CONFIGURATION_BUILD_DIR)/NAOSwiftProvider",
  }

end
