import 'package:flutter/material.dart';
import 'package:native_theme_mode/native_theme_mode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the last native-persisted mode before the first frame.
  await NativeThemeMode.instance.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: NativeThemeMode.instance.themeModeListenable,
      builder: (BuildContext context, ThemeMode mode, Widget? _) {
        return MaterialApp(
          title: 'native_theme_mode',
          // Host apps can also keep their own ThemeMode and only call
          // NativeThemeMode.instance.setThemeMode to sync Android splash.
          themeMode: mode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const _HomePage(),
        );
      },
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final ThemeMode mode = NativeThemeMode.instance.themeMode;

    return Scaffold(
      appBar: AppBar(title: const Text('native_theme_mode')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current mode: ${mode.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'On Android 12+, fully kill this app and reopen to see the '
              'splash match a light or dark choice. Hot restart does not '
              'change splash. iOS Launch Screen still follows the device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: mode == ThemeMode.light
                      ? null
                      : () async {
                          await NativeThemeMode.instance.setLight();
                        },
                  icon: const Icon(Icons.light_mode),
                  label: const Text('Light'),
                ),
                OutlinedButton.icon(
                  onPressed: mode == ThemeMode.dark
                      ? null
                      : () async {
                          await NativeThemeMode.instance.setDark();
                        },
                  icon: const Icon(Icons.dark_mode),
                  label: const Text('Dark'),
                ),
                OutlinedButton.icon(
                  onPressed: mode == ThemeMode.system
                      ? null
                      : () async {
                          await NativeThemeMode.instance.setSystem();
                        },
                  icon: const Icon(Icons.brightness_auto),
                  label: const Text('System'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
