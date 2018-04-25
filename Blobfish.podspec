#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |spec|
  spec.name         = 'Blobfish'
  spec.version      = '1.0.0'
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.homepage     = 'https://github.com/nodes-ios/Blobfish'
  spec.author             = { "Nodes Agency - iOS" => "ios@nodes.dk" }
  spec.summary      = 'Easily handle errors and present them to the user in a nice way.'
  spec.social_media_url   = "http://twitter.com/nodes_ios"
  spec.source       = { :git => 'https://github.com/nodes-ios/Blobfish.git', :tag => spec.version }
  spec.source_files = "Blobfish/Classes/**/*.{swift}"

  spec.swift_version = '3.3'

  spec.platforms = { :ios => "8.0" }
  spec.frameworks = 'UIKit', 'Foundation'
 # spec.dependency 'Alamofire'
  spec.preserve_paths = 'Carthage/Build/iOS/Alamofire.framework'
  spec.vendored_frameworks = 'Carthage/Build/iOS/Alamofire.framework'
  spec.static_framework = true


end