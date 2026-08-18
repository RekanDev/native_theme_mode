import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_theme_mode_method_channel.dart';

abstract class NativeThemeModePlatform extends PlatformInterface {
  /// Constructs a NativeThemeModePlatform.
  NativeThemeModePlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeThemeModePlatform _instance = MethodChannelNativeThemeMode();

  /// The default instance of [NativeThemeModePlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeThemeMode].
  static NativeThemeModePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeThemeModePlatform] when
  /// they register themselves.
  static set instance(NativeThemeModePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
