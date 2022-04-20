#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint forgerock_authenticator.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'forgerock_authenticator'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://forgerock.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FRAuthenticator', '3.1.0'

# Embedded frameworks
#   s.preserve_paths = 'FRAuthenticator.framework', 'FRCore.framework'
#   s.xcconfig = { 'OTHER_LDFLAGS' => '-framework FRAuthenticator' }
#   s.vendored_frameworks = 'FRAuthenticator.framework', 'FRCore.framework'

  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
