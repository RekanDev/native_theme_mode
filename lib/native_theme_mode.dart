/// Sync Flutter ThemeMode to native Android night mode and iOS UI style.
///
/// Host apps only write Dart: add the package, call
/// `NativeThemeMode.instance.ensureInitialized()`, then
/// `NativeThemeMode.instance.setThemeMode(...)`.
/// No `MainActivity`, `AppDelegate`, `AndroidManifest.xml`, or `Info.plist`
/// edits are required for this plugin.
library;

export 'src/native_theme_mode.dart';
export 'src/native_theme_mode_config.dart';
export 'src/native_theme_mode_method_channel.dart';
export 'src/native_theme_mode_platform_interface.dart';
