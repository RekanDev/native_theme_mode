# native_theme_mode

[![pub package](https://img.shields.io/pub/v/native_theme_mode.svg)](https://pub.dev/packages/native_theme_mode)

<p align="center">
  <img src="https://raw.githubusercontent.com/RekanDev/native_theme_mode/master/assets/logo/native_theme_mode_logo.png" alt="native_theme_mode logo" width="250"/>
</p>

Sync Flutter `ThemeMode` (light / dark / system) to the native platform so
Android 12+ splash uses the in-app theme on the next cold start, and iOS
`overrideUserInterfaceStyle` matches while the app is running.

Host apps only add the package and write Dart. This plugin contains all
native code. You do **not** edit `MainActivity.kt`, `AppDelegate.swift`,
`AndroidManifest.xml`, or `Info.plist` for this feature.

## Demo

<table align="center" style="border-collapse: collapse;">
  <tr>
    <td align="center" style="padding: 0 20px;">
      <strong>Manual Light / Dark</strong>
      <br/>
      <span style="display:block; height:10px;"></span>
      <img src="https://raw.githubusercontent.com/RekanDev/native_theme_mode/master/assets/demo.gif" alt="native_theme_mode manual theme demo" width="320"/>
    </td>
    <td align="center" style="padding: 0 20px;">
      <strong>System Mode</strong>
      <br/>
      <span style="display:block; height:10px;"></span>
      <img src="https://raw.githubusercontent.com/RekanDev/native_theme_mode/master/assets/demo_system.gif" alt="native_theme_mode system theme demo" width="320"/>
    </td>
  </tr>
</table>

## The problem

[`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash)
generates light and dark splash **assets**. It does not tell Android which
one to use for an **in-app** theme.

Android 12+ draws the splash **before Flutter starts**. That splash follows
the app’s persisted night mode from the **previous** session:

- API 31+: `UiModeManager.setApplicationNightMode(...)`
- API 30 and below: `AppCompatDelegate.setDefaultNightMode(...)`

There is no widely used Flutter plugin for this. Google’s Now in Android
makes the same native call by hand.

iOS Launch Screen **cannot** follow an in-app theme the same way. The
storyboard is shown by the system from **device** Dark Mode. This plugin
still sets `overrideUserInterfaceStyle` so the running iOS UI matches.

This package does **not** replace `flutter_native_splash`, and it does not
implement Flutter theming (`ThemeData`, Riverpod, Provider). Pair them:
splash generates assets; this plugin chooses which Android splash to show
on the next cold start.

## Install

```bash
flutter pub add native_theme_mode
```

Requires Flutter 3.10 or later (Dart 3.0).

## Minimal usage

```dart
import 'package:flutter/material.dart';
import 'package:native_theme_mode/native_theme_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NativeThemeMode.instance.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: NativeThemeMode.instance.themeModeListenable,
      builder: (context, mode, _) {
        return MaterialApp(
          themeMode: mode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const HomePage(),
        );
      },
    );
  }
}

// when the user toggles:
await NativeThemeMode.instance.setThemeMode(
  isDark ? ThemeMode.dark : ThemeMode.light,
);
```

Host apps may keep their own theme state and only call `setThemeMode` to
sync native. `MaterialApp.themeMode` can also read
`NativeThemeMode.instance.themeMode` directly.

Convenience methods: `setDark()`, `setLight()`, `setSystem()`.

## Pair with flutter_native_splash

Generate light and dark splash **assets**, then let this plugin pick which
Android uses:

```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.6

flutter_native_splash:
  color: "#FFFFFF"
  color_dark: "#121212"
  android_12:
    color: "#FFFFFF"
    color_dark: "#121212"
```

```bash
dart run flutter_native_splash:create
```

On iOS, `color_dark` still helps when the **device** is in Dark Mode. It
does not make the Launch Screen follow an in-app-only dark theme.

## Configuration

`configure` is optional. Defaults already cover the simple case.

```dart
await NativeThemeMode.instance.configure(
  const NativeThemeModeConfig(
    storageKey: 'theme_mode',
    defaultMode: ThemeMode.system,
    persist: true,
    enableAndroid: true,
    enableIOS: true,
  ),
);
```

| Option | Default | Notes |
| --- | --- | --- |
| `storageKey` | `'theme_mode'` | Key **inside the plugin’s** SharedPreferences / `UserDefaults` file (`native_theme_mode`). Not the host app’s prefs. Native code always opens the plugin file, so host apps never write native code. Changing this is advanced: Dart writes the custom name to the well-known meta key `storage_key`. |
| `defaultMode` | `ThemeMode.system` | Used if nothing was saved yet. |
| `persist` | `true` | If false, only apply for this process; the next Android splash may not match. |
| `enableAndroid` | `true` | Apply native night mode on Android. |
| `enableIOS` | `true` | Apply `overrideUserInterfaceStyle` on iOS. |

Do **not** choose a custom SharedPreferences **file name**. Cold start
cannot read a key that only Dart knows. The native file name is always
`native_theme_mode`. Reserved key names: `storage_key`, `default_mode`,
`enable_android`, `enable_ios`, `persist`.

## Android behavior

On `setThemeMode`:

- Persist `"light"` / `"dark"` / `"system"` in the plugin prefs file.
- API 31+: `UiModeManager.setApplicationNightMode(MODE_NIGHT_NO / YES / AUTO)`.
- Else: `AppCompatDelegate.setDefaultNightMode(MODE_NIGHT_NO / YES / FOLLOW_SYSTEM)`.

The splash of the **current** launch is decided by the OS from the
**previous** `setApplicationNightMode`. To see a new splash:

1. Toggle the theme in the app (`setThemeMode`).
2. Fully kill the app (not just background it).
3. Open it again.

Hot reload and hot restart do **not** change splash.

Host `MainActivity` stays `FlutterActivity`. No manifest edits are
required. Flutter already lists `uiMode` in `android:configChanges`;
setting night mode should not recreate the activity. The plugin adds
`androidx.appcompat:appcompat` itself.

No custom `Application` class is required.

## iOS

iOS already follows the **device** Dark Mode setting by default. If you
do not use this plugin on iOS (or you leave `ThemeMode.system`), launch
screen and running UI still match the phone. You do not need this package
for “follow the system” on iOS.

Use the iOS side when the **in-app** theme should stay light or dark even
if the device is the opposite. Then the plugin sets
`window.overrideUserInterfaceStyle` to `.light`, `.dark`, or
`.unspecified` (system) and persists that in the plugin’s `UserDefaults`
suite.

The Launch Screen / storyboard still uses **system** appearance. Plugin
registration runs **after** the Launch Screen, so this package cannot
change that splash for an in-app-only theme. That is an OS limit, not a
missing feature.

iOS native code ships as both a [Swift package](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors)
and a CocoaPods podspec. Flutter 3.24+ apps can use Swift Package Manager;
older apps keep using CocoaPods. Flutter will keep CocoaPods in maintenance
mode until the CocoaPods registry becomes read-only
([December 2, 2026](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)).

## Unsupported platforms

Web and desktop have no native night-mode splash hook. Calls succeed as
no-ops: Dart `themeMode` still updates so `MaterialApp` works, and
nothing is written to a host prefs file.

## FAQ

**Why is this launch’s splash still wrong?**

The previous session had not called `setThemeMode` yet, or you did not
fully kill the app after toggling. Android 12+ splash is chosen before
Flutter starts, from the last persisted application night mode.

**Does this replace `flutter_native_splash`?**

No. That package generates assets. This package tells Android which
night mode to use on the next cold start.

**Can iOS Launch Screen follow my in-app theme?**

No. iOS already follows the device Dark Mode setting by default. That
includes the Launch Screen. This plugin only overrides the **running**
UI when you pick an in-app light or dark theme.

## API reference

Public types (see dartdoc on each member):

- [`NativeThemeMode`](https://pub.dev/documentation/native_theme_mode/latest/native_theme_mode/NativeThemeMode-class.html) — singleton API: `ensureInitialized`, `configure`, `setThemeMode`, `themeMode`, `themeModeListenable`, `setDark` / `setLight` / `setSystem`
- [`NativeThemeModeConfig`](https://pub.dev/documentation/native_theme_mode/latest/native_theme_mode/NativeThemeModeConfig-class.html) — optional settings
- [`NativeThemeModePlatform`](https://pub.dev/documentation/native_theme_mode/latest/native_theme_mode/NativeThemeModePlatform-class.html) — platform interface for tests and federated implementations

## License

MIT. See [LICENSE](LICENSE).

Source: [github.com/RekanDev/native_theme_mode](https://github.com/RekanDev/native_theme_mode)
