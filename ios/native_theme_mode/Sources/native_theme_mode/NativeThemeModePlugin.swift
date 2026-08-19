import Flutter
import UIKit

public class NativeThemeModePlugin: NSObject, FlutterPlugin {
  private static let channelName = "dev.rekan.native_theme_mode"
  private static let suiteName = "native_theme_mode"
  private static let metaStorageKey = "storage_key"
  private static let metaDefaultMode = "default_mode"
  private static let metaPersist = "persist"
  private static let metaEnableIOS = "enable_ios"
  private static let defaultDataKey = "theme_mode"
  private static let modeLight = "light"
  private static let modeDark = "dark"
  private static let modeSystem = "system"
  private static let reservedKeys: Set<String> = [
    metaStorageKey, metaDefaultMode, metaPersist, metaEnableIOS,
  ]

  private let defaults =
    UserDefaults(suiteName: NativeThemeModePlugin.suiteName) ?? .standard

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = NativeThemeModePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    instance.applyFromDefaults()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "configure":
      result(configure(arguments: call.arguments))
    case "getThemeMode":
      result(currentMode())
    case "setThemeMode":
      setThemeMode(arguments: call.arguments)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func configure(arguments: Any?) -> String {
    let args = dictionary(from: arguments)
    let storageKey = Self.sanitizeStorageKey(args.stringValue("storageKey") ?? Self.defaultDataKey)
    let defaultMode = Self.sanitizeMode(args.stringValue("defaultMode"))
    let persist = args.boolValue("persist") ?? true
    let enableIOS = args.boolValue("enableIOS") ?? true

    defaults.set(storageKey, forKey: Self.metaStorageKey)
    defaults.set(defaultMode, forKey: Self.metaDefaultMode)
    defaults.set(persist, forKey: Self.metaPersist)
    defaults.set(enableIOS, forKey: Self.metaEnableIOS)

    let mode = currentMode()
    if enableIOS {
      applyUserInterfaceStyle(mode)
    }
    return mode
  }

  private func setThemeMode(arguments: Any?) {
    let args = dictionary(from: arguments)
    let mode = Self.sanitizeMode(args.stringValue("mode"))
    let persist = args.boolValue("persist") ?? defaults.bool(forKey: Self.metaPersist, default: true)
    let enableIOS =
      args.boolValue("enableIOS") ?? defaults.bool(forKey: Self.metaEnableIOS, default: true)

    if persist {
      defaults.set(mode, forKey: dataKey())
    }
    if enableIOS {
      applyUserInterfaceStyle(mode)
    }
  }

  private func applyFromDefaults() {
    let enableIOS = defaults.object(forKey: Self.metaEnableIOS) as? Bool ?? true
    guard enableIOS else { return }
    applyUserInterfaceStyle(currentMode())
  }

  private func applyUserInterfaceStyle(_ mode: String) {
    let style: UIUserInterfaceStyle
    switch mode {
    case Self.modeLight:
      style = .light
    case Self.modeDark:
      style = .dark
    default:
      style = .unspecified
    }

    let apply: () -> Void = {
      for window in self.keyWindows() {
        window.overrideUserInterfaceStyle = style
      }
    }

    if Thread.isMainThread {
      apply()
    } else {
      DispatchQueue.main.async(execute: apply)
    }
  }

  private func currentMode() -> String {
    let defaultMode = Self.sanitizeMode(defaults.string(forKey: Self.metaDefaultMode))
    return Self.sanitizeMode(defaults.string(forKey: dataKey()) ?? defaultMode)
  }

  private func dataKey() -> String {
    Self.sanitizeStorageKey(defaults.string(forKey: Self.metaStorageKey) ?? Self.defaultDataKey)
  }

  private func keyWindows() -> [UIWindow] {
    if #available(iOS 13.0, *) {
      return UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
    }
    return UIApplication.shared.windows
  }

  private func dictionary(from arguments: Any?) -> [String: Any] {
    arguments as? [String: Any] ?? [:]
  }

  static func sanitizeStorageKey(_ key: String) -> String {
    if key.isEmpty || reservedKeys.contains(key) {
      return defaultDataKey
    }
    return key
  }

  static func sanitizeMode(_ mode: String?) -> String {
    switch mode {
    case modeLight, modeDark, modeSystem:
      return mode!
    default:
      return modeSystem
    }
  }
}

private extension Dictionary where Key == String, Value == Any {
  func stringValue(_ key: String) -> String? {
    self[key] as? String
  }

  func boolValue(_ key: String) -> Bool? {
    self[key] as? Bool
  }
}

private extension UserDefaults {
  func bool(forKey key: String, default defaultValue: Bool) -> Bool {
    if object(forKey: key) == nil {
      return defaultValue
    }
    return bool(forKey: key)
  }
}
