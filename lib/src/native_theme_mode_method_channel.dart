import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_theme_mode_platform_interface.dart';
import 'theme_mode_codec.dart';

/// Method-channel implementation of [NativeThemeModePlatform].
///
/// On platforms without a native plugin (web, desktop), every call is a
/// no-op and stored values stay in memory for this isolate.
class MethodChannelNativeThemeMode extends NativeThemeModePlatform {
  /// The method channel used to talk to Android and iOS.
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel(
    'dev.rekan.native_theme_mode',
  );

  String _memoryMode = kNativeThemeModeSystem;

  @override
  Future<String> configure({
    required String storageKey,
    required String defaultMode,
    required bool persist,
    required bool enableAndroid,
    required bool enableIOS,
  }) async {
    _memoryMode = defaultMode;
    final String? result = await _invoke<String>('configure', <String, Object?>{
      'storageKey': storageKey,
      'defaultMode': defaultMode,
      'persist': persist,
      'enableAndroid': enableAndroid,
      'enableIOS': enableIOS,
    });
    final String mode = result ?? defaultMode;
    _memoryMode = mode;
    return mode;
  }

  @override
  Future<String> getThemeMode() async {
    final String? result = await _invoke<String>('getThemeMode');
    return result ?? _memoryMode;
  }

  @override
  Future<void> setThemeMode({
    required String mode,
    required bool persist,
    required bool enableAndroid,
    required bool enableIOS,
  }) async {
    _memoryMode = mode;
    await _invoke<void>('setThemeMode', <String, Object?>{
      'mode': mode,
      'persist': persist,
      'enableAndroid': enableAndroid,
      'enableIOS': enableIOS,
    });
  }

  Future<T?> _invoke<T>(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      return await methodChannel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      // Web, desktop, and tests without a mock: native is a documented no-op.
      return null;
    }
  }
}
