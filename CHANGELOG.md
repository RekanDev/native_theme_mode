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
