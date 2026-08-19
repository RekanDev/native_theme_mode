import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_theme_mode/native_theme_mode.dart';

class FakeNativeThemeModePlatform extends NativeThemeModePlatform {
  String storedMode = 'system';
  String? lastStorageKey;
  String? lastDefaultMode;
  bool? lastPersist;
  bool? lastEnableAndroid;
  bool? lastEnableIOS;
  String? lastSetMode;
  int configureCount = 0;

  @override
  Future<String> configure({
    required String storageKey,
    required String defaultMode,
    required bool persist,
    required bool enableAndroid,
    required bool enableIOS,
  }) async {
    lastStorageKey = storageKey;
    lastDefaultMode = defaultMode;
    lastPersist = persist;
    lastEnableAndroid = enableAndroid;
    lastEnableIOS = enableIOS;
    configureCount++;
    return storedMode;
  }

  @override
  Future<String> getThemeMode() async => storedMode;

  @override
  Future<void> setThemeMode({
    required String mode,
    required bool persist,
    required bool enableAndroid,
    required bool enableIOS,
  }) async {
    lastSetMode = mode;
    lastPersist = persist;
    lastEnableAndroid = enableAndroid;
    lastEnableIOS = enableIOS;
    storedMode = mode;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final NativeThemeModePlatform defaultPlatform =
      NativeThemeModePlatform.instance;

  setUp(() {
    NativeThemeMode.instance.debugReset();
  });

  tearDown(() {
    NativeThemeModePlatform.instance = defaultPlatform;
    NativeThemeMode.instance.debugReset();
  });

  test('MethodChannelNativeThemeMode is the default instance', () {
    expect(defaultPlatform, isA<MethodChannelNativeThemeMode>());
  });

  test('ensureInitialized loads stored native mode', () async {
    final FakeNativeThemeModePlatform fake = FakeNativeThemeModePlatform()
      ..storedMode = 'dark';
    NativeThemeModePlatform.instance = fake;

    await NativeThemeMode.instance.ensureInitialized();

    expect(NativeThemeMode.instance.themeMode, ThemeMode.dark);
    expect(NativeThemeMode.instance.isInitialized, isTrue);
    expect(fake.lastStorageKey, 'theme_mode');
    expect(fake.lastDefaultMode, 'system');
  });

  test('ensureInitialized is idempotent', () async {
    final FakeNativeThemeModePlatform fake = FakeNativeThemeModePlatform();
    NativeThemeModePlatform.instance = fake;

    await NativeThemeMode.instance.ensureInitialized();
    fake.lastStorageKey = null;
    await NativeThemeMode.instance.ensureInitialized();

    expect(fake.lastStorageKey, isNull);
  });

  test('ensureInitialized is safe to call concurrently', () async {
    final FakeNativeThemeModePlatform fake = FakeNativeThemeModePlatform()
      ..storedMode = 'light';
    NativeThemeModePlatform.instance = fake;

    await Future.wait<void>(<Future<void>>[
      NativeThemeMode.instance.ensureInitialized(),
      NativeThemeMode.instance.ensureInitialized(),
    ]);

    expect(fake.configureCount, 1);
    expect(NativeThemeMode.instance.themeMode, ThemeMode.light);
  });

  test('setThemeMode updates Dart state and native', () async {
    final FakeNativeThemeModePlatform fake = FakeNativeThemeModePlatform();
    NativeThemeModePlatform.instance = fake;

    await NativeThemeMode.instance.setDark();

    expect(NativeThemeMode.instance.themeMode, ThemeMode.dark);
    expect(fake.lastSetMode, 'dark');
    expect(fake.lastPersist, isTrue);
  });

  test('setLight and setSystem map to native strings', () async {
    final FakeNativeThemeModePlatform fake = FakeNativeThemeModePlatform();
    NativeThemeModePlatform.instance = fake;

    await NativeThemeMode.instance.setLight();
    expect(fake.lastSetMode, 'light');

    await NativeThemeMode.instance.setSystem();
    expect(fake.lastSetMode, 'system');
    expect(NativeThemeMode.instance.themeMode, ThemeMode.system);
  });

  test('configure after init re-reads native storage', () async {
    final FakeNativeThemeModePlatform fake = FakeNativeThemeModePlatform()
      ..storedMode = 'light';
    NativeThemeModePlatform.instance = fake;

    await NativeThemeMode.instance.ensureInitialized();
    fake.storedMode = 'dark';

    await NativeThemeMode.instance.configure(
      const NativeThemeModeConfig(
        storageKey: 'custom_key',
        defaultMode: ThemeMode.light,
        persist: false,
        enableAndroid: false,
        enableIOS: false,
      ),
    );

    expect(fake.lastStorageKey, 'custom_key');
    expect(fake.lastDefaultMode, 'light');
    expect(fake.lastPersist, isFalse);
    expect(fake.lastEnableAndroid, isFalse);
    expect(fake.lastEnableIOS, isFalse);
    expect(NativeThemeMode.instance.themeMode, ThemeMode.dark);
  });

  test('themeModeListenable notifies on setThemeMode', () async {
    final FakeNativeThemeModePlatform fake = FakeNativeThemeModePlatform();
    NativeThemeModePlatform.instance = fake;

    final List<ThemeMode> seen = <ThemeMode>[];
    NativeThemeMode.instance.themeModeListenable.addListener(() {
      seen.add(NativeThemeMode.instance.themeMode);
    });

    await NativeThemeMode.instance.setThemeMode(ThemeMode.light);
    expect(seen, <ThemeMode>[ThemeMode.light]);
  });
}
