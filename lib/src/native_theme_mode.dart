import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'native_theme_mode_config.dart';
import 'native_theme_mode_platform_interface.dart';
import 'theme_mode_codec.dart';

/// Syncs Flutter [ThemeMode] to the native platform.
///
/// Call [ensureInitialized] once from `main` after
/// [WidgetsFlutterBinding.ensureInitialized]. Then pass [themeMode] to
/// [MaterialApp], and call [setThemeMode] when the user changes theme.
///
/// On Android 12+, `UiModeManager.setApplicationNightMode` makes the
/// **next** cold-start splash follow the last saved light/dark mode.
/// Hot reload and hot restart do not change the splash of the current
/// launch.
///
/// On iOS, `window.overrideUserInterfaceStyle` is updated for the running
/// app. The Launch Screen still follows **device** Dark Mode; that is an
/// OS limit.
///
/// Web and desktop have no native implementation; calls succeed as no-ops
/// and Dart state still updates so [MaterialApp.themeMode] works.
class NativeThemeMode {
  NativeThemeMode._();

  /// The shared plugin instance.
  static final NativeThemeMode instance = NativeThemeMode._();

  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  NativeThemeModeConfig _config = const NativeThemeModeConfig();
  bool _initialized = false;
  Future<void>? _initFuture;

  /// Current theme mode last applied through this plugin.
  ///
  /// Use this (or [themeModeListenable]) with [MaterialApp.themeMode].
  /// Call [ensureInitialized] first so a previously persisted native
  /// value is loaded.
  ThemeMode get themeMode => _themeMode.value;

  /// Listens for [themeMode] changes.
  ///
  /// Rebuild [MaterialApp] from this when the user toggles theme.
  ValueListenable<ThemeMode> get themeModeListenable => _themeMode;

  /// Last configuration passed to [configure], or the defaults.
  NativeThemeModeConfig get config => _config;

  /// Whether [ensureInitialized] has completed in this isolate.
  bool get isInitialized => _initialized;

  /// Loads the persisted mode from native and applies it.
  ///
  /// Safe to call more than once, including concurrently. Host apps should
  /// call this in `main` before [runApp]:
  ///
  /// ```dart
  /// WidgetsFlutterBinding.ensureInitialized();
  /// await NativeThemeMode.instance.ensureInitialized();
  /// runApp(const MyApp());
  /// ```
  Future<void> ensureInitialized() {
    return _initFuture ??= _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    try {
      final String stored = await NativeThemeModePlatform.instance.configure(
        storageKey: _config.storageKey,
        defaultMode: themeModeToNativeString(_config.defaultMode),
        persist: _config.persist,
        enableAndroid: _config.enableAndroid,
        enableIOS: _config.enableIOS,
      );
      _themeMode.value = themeModeFromNativeString(stored);
      _initialized = true;
    } catch (_) {
      _initFuture = null;
      rethrow;
    }
  }

  /// Updates optional settings. Defaults already cover the simple case.
  ///
  /// May be called before or after [ensureInitialized]. If called after,
  /// native storage is re-read with the new options.
  Future<void> configure(NativeThemeModeConfig config) async {
    _config = config;
    if (!_initialized) {
      return;
    }
    final String stored = await NativeThemeModePlatform.instance.configure(
      storageKey: config.storageKey,
      defaultMode: themeModeToNativeString(config.defaultMode),
      persist: config.persist,
      enableAndroid: config.enableAndroid,
      enableIOS: config.enableIOS,
    );
    _themeMode.value = themeModeFromNativeString(stored);
  }

  /// Persists (unless [NativeThemeModeConfig.persist] is false) and applies
  /// [mode] on the native platform.
  ///
  /// On Android 12+, the splash of the **next** cold start uses this mode
  /// when [mode] is [ThemeMode.light] or [ThemeMode.dark]. Fully kill the
  /// app and reopen to see it; the current launch's splash was already
  /// decided by the previous session.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (!_initialized) {
      await ensureInitialized();
    }
    _themeMode.value = mode;
    await NativeThemeModePlatform.instance.setThemeMode(
      mode: themeModeToNativeString(mode),
      persist: _config.persist,
      enableAndroid: _config.enableAndroid,
      enableIOS: _config.enableIOS,
    );
  }

  /// Shortcut for [setThemeMode] with [ThemeMode.dark].
  Future<void> setDark() => setThemeMode(ThemeMode.dark);

  /// Shortcut for [setThemeMode] with [ThemeMode.light].
  Future<void> setLight() => setThemeMode(ThemeMode.light);

  /// Shortcut for [setThemeMode] with [ThemeMode.system].
  Future<void> setSystem() => setThemeMode(ThemeMode.system);

  /// Restores plugin Dart state. Used by tests.
  @visibleForTesting
  void debugReset() {
    _initialized = false;
    _initFuture = null;
    _config = const NativeThemeModeConfig();
    _themeMode.value = ThemeMode.system;
  }
}
