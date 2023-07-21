#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint forgerock_authenticator.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'forgerock_authenticator'
  s.version          = '1.2.0'
  s.summary          = 'ForgeRock Authenticator Plugin'
  s.description      = <<-DESC
  ForgeRock Authenticator plugin allows you to build the power of the official ForgeRock Authenticator application into your own Flutter app.
                       DESC
  s.homepage         = 'http://forgerock.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ForgeRock' => 'sdk@forgerock.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.platform = :ios, '12.0'
  s.dependency 'Flutter'
  s.dependency 'FRAuthenticator', '4.1.0-beta2'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
