import 'package:flutter/material.dart';

/// Native string stored in the plugin preferences file.
const String kNativeThemeModeLight = 'light';

/// Native string stored in the plugin preferences file.
const String kNativeThemeModeDark = 'dark';

/// Native string stored in the plugin preferences file.
const String kNativeThemeModeSystem = 'system';

/// Converts a Flutter [ThemeMode] to the plugin's native string.
///
/// Values are `'light'`, `'dark'`, or `'system'`.
String themeModeToNativeString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return kNativeThemeModeLight;
    case ThemeMode.dark:
      return kNativeThemeModeDark;
    case ThemeMode.system:
      return kNativeThemeModeSystem;
  }
}

/// Converts a native stored string to a Flutter [ThemeMode].
///
/// Unknown or empty values map to [ThemeMode.system].
ThemeMode themeModeFromNativeString(String? value) {
  switch (value) {
    case kNativeThemeModeLight:
      return ThemeMode.light;
    case kNativeThemeModeDark:
      return ThemeMode.dark;
    case kNativeThemeModeSystem:
      return ThemeMode.system;
    default:
      return ThemeMode.system;
  }
}
