
import 'native_theme_mode_platform_interface.dart';

class NativeThemeMode {
  Future<String?> getPlatformVersion() {
    return NativeThemeModePlatform.instance.getPlatformVersion();
  }
}
