import 'package:flutter_test/flutter_test.dart';
import 'package:native_theme_mode/native_theme_mode.dart';
import 'package:native_theme_mode/native_theme_mode_platform_interface.dart';
import 'package:native_theme_mode/native_theme_mode_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeThemeModePlatform
    with MockPlatformInterfaceMixin
    implements NativeThemeModePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeThemeModePlatform initialPlatform = NativeThemeModePlatform.instance;

  test('$MethodChannelNativeThemeMode is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeThemeMode>());
  });

  test('getPlatformVersion', () async {
    NativeThemeMode nativeThemeModePlugin = NativeThemeMode();
    MockNativeThemeModePlatform fakePlatform = MockNativeThemeModePlatform();
    NativeThemeModePlatform.instance = fakePlatform;

    expect(await nativeThemeModePlugin.getPlatformVersion(), '42');
  });
}
