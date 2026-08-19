import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_theme_mode/native_theme_mode.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('setThemeMode updates Dart state', (WidgetTester tester) async {
    await NativeThemeMode.instance.ensureInitialized();
    await NativeThemeMode.instance.setDark();
    expect(NativeThemeMode.instance.themeMode, ThemeMode.dark);

    await NativeThemeMode.instance.setLight();
    expect(NativeThemeMode.instance.themeMode, ThemeMode.light);
  });
}
