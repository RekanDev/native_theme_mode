import 'package:flutter/material.dart';

/// Options for [NativeThemeMode.configure].
///
/// Defaults are chosen so most apps never need to call `configure`.
///
/// Native code always opens the plugin's own preferences file
/// (`native_theme_mode`), not the host app's SharedPreferences /
/// `UserDefaults`. Changing [storageKey] only changes the key **inside**
/// that file.
class NativeThemeModeConfig {
  /// Creates plugin configuration.
  const NativeThemeModeConfig({
    this.storageKey = 'theme_mode',
    this.defaultMode = ThemeMode.system,
    this.persist = true,
    this.enableAndroid = true,
    this.enableIOS = true,
  });

  /// Key inside the plugin preferences file (`native_theme_mode`).
  ///
  /// Default: `'theme_mode'`.
  ///
  /// This is **not** a SharedPreferences file name. Cold start always
  /// reads the hardcoded plugin file. If you change this value, Dart
  /// writes it to the well-known meta key `storage_key` so native code
  /// can still find the mode with zero host native edits.
  ///
  /// Do not use the reserved names `storage_key`, `default_mode`,
  /// `enable_android`, `enable_ios`, or `persist`.
  final String storageKey;

  /// Mode used when nothing has been saved yet.
  ///
  /// Default: [ThemeMode.system].
  final ThemeMode defaultMode;

  /// Whether to persist the mode for the next process / Android splash.
  ///
  /// Default: `true`.
  ///
  /// If `false`, the mode is applied for this process only. The next
  /// Android 12+ splash may not match because
  /// `UiModeManager.setApplicationNightMode` is not updated.
  final bool persist;

  /// Whether to apply native night mode on Android.
  ///
  /// Default: `true`.
  final bool enableAndroid;

  /// Whether to apply `overrideUserInterfaceStyle` on iOS.
  ///
  /// Default: `true`.
  ///
  /// This does **not** change the iOS Launch Screen; that always follows
  /// the device appearance.
  final bool enableIOS;

  /// Configurations with the same fields are equal.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NativeThemeModeConfig &&
        other.storageKey == storageKey &&
        other.defaultMode == defaultMode &&
        other.persist == persist &&
        other.enableAndroid == enableAndroid &&
        other.enableIOS == enableIOS;
  }

  /// Hash code based on all configuration fields.
  @override
  int get hashCode =>
      Object.hash(storageKey, defaultMode, persist, enableAndroid, enableIOS);
}
