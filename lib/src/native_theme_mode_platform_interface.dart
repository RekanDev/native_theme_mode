import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_theme_mode_method_channel.dart';

/// The interface that platform implementations of `native_theme_mode` must
/// implement.
///
/// Platform implementations should set [instance] to their own class that
/// extends [NativeThemeModePlatform] when they register themselves.
/// Tests can install a fake implementation the same way.
abstract class NativeThemeModePlatform extends PlatformInterface {
  /// Constructs a [NativeThemeModePlatform].
  NativeThemeModePlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeThemeModePlatform _instance = MethodChannelNativeThemeMode();

  /// The default instance of [NativeThemeModePlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeThemeMode].
  static NativeThemeModePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// class that extends [NativeThemeModePlatform] when they register.
  static set instance(NativeThemeModePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Pushes configuration to native code and returns the stored mode string.
  ///
  /// The returned value is `'light'`, `'dark'`, or `'system'`.
  Future<String> configure({
    required String storageKey,
    required String defaultMode,
    required bool persist,
    required bool enableAndroid,
    required bool enableIOS,
  }) {
    throw UnimplementedError('configure() has not been implemented.');
  }

  /// Returns the stored native mode string.
  Future<String> getThemeMode() {
    throw UnimplementedError('getThemeMode() has not been implemented.');
  }

  /// Applies [mode] (`'light'`, `'dark'`, or `'system'`) on the native side.
  Future<void> setThemeMode({
    required String mode,
    required bool persist,
    required bool enableAndroid,
    required bool enableIOS,
  }) {
    throw UnimplementedError('setThemeMode() has not been implemented.');
  }
}
