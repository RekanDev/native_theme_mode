import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_theme_mode/src/theme_mode_codec.dart';

void main() {
  group('themeModeToNativeString', () {
    test('maps each ThemeMode to a stable native string', () {
      expect(themeModeToNativeString(ThemeMode.light), kNativeThemeModeLight);
      expect(themeModeToNativeString(ThemeMode.dark), kNativeThemeModeDark);
      expect(themeModeToNativeString(ThemeMode.system), kNativeThemeModeSystem);
    });
  });

  group('themeModeFromNativeString', () {
    test('maps native strings back to ThemeMode', () {
      expect(themeModeFromNativeString('light'), ThemeMode.light);
      expect(themeModeFromNativeString('dark'), ThemeMode.dark);
      expect(themeModeFromNativeString('system'), ThemeMode.system);
    });

    test('unknown or empty values become ThemeMode.system', () {
      expect(themeModeFromNativeString(null), ThemeMode.system);
      expect(themeModeFromNativeString(''), ThemeMode.system);
      expect(themeModeFromNativeString('nope'), ThemeMode.system);
    });

    test('round-trips every ThemeMode', () {
      for (final ThemeMode mode in ThemeMode.values) {
        expect(themeModeFromNativeString(themeModeToNativeString(mode)), mode);
      }
    });
  });
}
