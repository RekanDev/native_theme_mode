#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_theme_mode.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_theme_mode'
  s.version          = '0.1.0'
  s.summary          = 'Sync Flutter ThemeMode to native Android night mode and iOS UI style.'
  s.description      = <<-DESC
Sync Flutter ThemeMode (light / dark / system) to the native platform so Android 12+ splash uses the in-app theme on the next cold start, and iOS overrideUserInterfaceStyle matches while the app is running.
                       DESC
  s.homepage         = 'https://github.com/RekanDev/native_theme_mode'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'RekanDev' => 'https://github.com/RekanDev' }
  s.source           = { :path => '.' }
  s.source_files = 'native_theme_mode/Sources/native_theme_mode/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'native_theme_mode_privacy' => ['native_theme_mode/Sources/native_theme_mode/PrivacyInfo.xcprivacy']}
end
