import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_theme_mode/native_theme_mode.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelNativeThemeMode platform;
  const MethodChannel channel = MethodChannel('dev.rekan.native_theme_mode');

  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    platform = MethodChannelNativeThemeMode();
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'configure':
          return 'dark';
        case 'getThemeMode':
          return 'light';
        case 'setThemeMode':
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('configure sends options and returns stored mode', () async {
    final String mode = await platform.configure(
      storageKey: 'theme_mode',
      defaultMode: 'system',
      persist: true,
      enableAndroid: true,
      enableIOS: true,
    );

    expect(mode, 'dark');
    expect(log, hasLength(1));
    expect(log.single.method, 'configure');
    expect(log.single.arguments, <String, Object?>{
      'storageKey': 'theme_mode',
      'defaultMode': 'system',
      'persist': true,
      'enableAndroid': true,
      'enableIOS': true,
    });
  });

  test('getThemeMode returns native string', () async {
    expect(await platform.getThemeMode(), 'light');
  });

  test('setThemeMode sends mode and flags', () async {
    await platform.setThemeMode(
      mode: 'light',
      persist: false,
      enableAndroid: true,
      enableIOS: false,
    );

    expect(log.single.method, 'setThemeMode');
    expect(log.single.arguments, <String, Object?>{
      'mode': 'light',
      'persist': false,
      'enableAndroid': true,
      'enableIOS': false,
    });
  });

  test('missing plugin is a no-op and returns defaultMode', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);

    final String mode = await platform.configure(
      storageKey: 'theme_mode',
      defaultMode: 'light',
      persist: true,
      enableAndroid: true,
      enableIOS: true,
    );

    expect(mode, 'light');
  });
}
