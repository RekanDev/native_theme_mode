## 0.3.0

* Add pub.dev screenshots for the manual and system theme demos.
* Update README image links to raw GitHub URLs for reliable rendering on pub.dev.
* Align analysis options with Flutter 3.47 exclude defaults for CI stability.

## 0.2.0

* Refresh the package README with the new logo and demo presentation updates.

## 0.1.0

* Initial release: sync Flutter `ThemeMode` to Android application night mode
  and iOS `overrideUserInterfaceStyle`.
* Android 12+ splash follows the last saved light/dark mode on the next cold
  start via `UiModeManager.setApplicationNightMode`.
* Dart-only host API; no `MainActivity`, `AppDelegate`, manifest, or
  `Info.plist` edits required.
* Minimum Flutter 3.10 / Dart 3.0.
* Minimum iOS 12 (window-scene APIs on iOS 13+).
* iOS plugin supports Swift Package Manager and CocoaPods.
