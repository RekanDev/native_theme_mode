import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_theme_mode_platform_interface.dart';

/// An implementation of [NativeThemeModePlatform] that uses method channels.
class MethodChannelNativeThemeMode extends NativeThemeModePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_theme_mode');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
