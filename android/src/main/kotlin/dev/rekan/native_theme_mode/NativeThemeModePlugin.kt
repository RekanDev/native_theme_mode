package dev.rekan.native_theme_mode

import android.app.UiModeManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import androidx.appcompat.app.AppCompatDelegate
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** NativeThemeModePlugin */
class NativeThemeModePlugin :
    FlutterPlugin,
    ActivityAware,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel =
            MethodChannel(
                flutterPluginBinding.binaryMessenger,
                CHANNEL
            )
        channel.setMethodCallHandler(this)
        applyFromPrefs()
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "configure" -> {
                if (!ensureContext(result)) {
                    return
                }
                result.success(configure(call.argumentsMap()))
            }
            "getThemeMode" -> {
                if (!ensureContext(result)) {
                    return
                }
                result.success(currentMode())
            }
            "setThemeMode" -> {
                if (!ensureContext(result)) {
                    return
                }
                setThemeMode(call.argumentsMap())
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (::context.isInitialized) {
            applyFromPrefs()
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}

    private fun ensureContext(result: Result): Boolean {
        if (!::context.isInitialized) {
            result.error("not_attached", "Plugin is not attached to an engine", null)
            return false
        }
        return true
    }

    private fun configure(args: Map<String, Any?>): String {
        val requestedKey = args.stringArg("storageKey") ?: DEFAULT_DATA_KEY
        val storageKey = sanitizeStorageKey(requestedKey)
        val defaultMode = sanitizeMode(args.stringArg("defaultMode"))
        val persist = args.boolArg("persist") ?: true
        val enableAndroid = args.boolArg("enableAndroid") ?: true

        prefs()
            .edit()
            .putString(META_STORAGE_KEY, storageKey)
            .putString(META_DEFAULT_MODE, defaultMode)
            .putBoolean(META_PERSIST, persist)
            .putBoolean(META_ENABLE_ANDROID, enableAndroid)
            .apply()

        val mode = currentMode()
        if (enableAndroid) {
            applyNightMode(mode, persistOs = persist)
        }
        return mode
    }

    private fun setThemeMode(args: Map<String, Any?>) {
        val mode = sanitizeMode(args.stringArg("mode"))
        val persist = args.boolArg("persist") ?: prefs().getBoolean(META_PERSIST, true)
        val enableAndroid =
            args.boolArg("enableAndroid") ?: prefs().getBoolean(META_ENABLE_ANDROID, true)

        if (persist) {
            prefs().edit().putString(dataKey(), mode).commit()
        }
        if (enableAndroid) {
            applyNightMode(mode, persistOs = persist)
        }
    }

    private fun applyFromPrefs() {
        if (!::context.isInitialized) {
            return
        }
        if (!prefs().getBoolean(META_ENABLE_ANDROID, true)) {
            return
        }
        val persist = prefs().getBoolean(META_PERSIST, true)
        applyNightMode(currentMode(), persistOs = persist)
    }

    private fun applyNightMode(
        mode: String,
        persistOs: Boolean
    ) {
        val appCompatMode =
            when (mode) {
                MODE_LIGHT -> AppCompatDelegate.MODE_NIGHT_NO
                MODE_DARK -> AppCompatDelegate.MODE_NIGHT_YES
                else -> AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM
            }

        // AppCompat default night mode updates this process. Flutter activities
        // typically list uiMode in configChanges, so this should not recreate
        // the activity.
        AppCompatDelegate.setDefaultNightMode(appCompatMode)

        if (persistOs && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val uiModeManager = context.getSystemService(UiModeManager::class.java)
            val uiMode =
                when (mode) {
                    MODE_LIGHT -> UiModeManager.MODE_NIGHT_NO
                    MODE_DARK -> UiModeManager.MODE_NIGHT_YES
                    else -> UiModeManager.MODE_NIGHT_AUTO
                }
            uiModeManager.setApplicationNightMode(uiMode)
        }
    }

    private fun currentMode(): String {
        val defaultMode = prefs().getString(META_DEFAULT_MODE, MODE_SYSTEM) ?: MODE_SYSTEM
        return prefs().getString(dataKey(), defaultMode) ?: defaultMode
    }

    private fun dataKey(): String {
        val stored = prefs().getString(META_STORAGE_KEY, DEFAULT_DATA_KEY) ?: DEFAULT_DATA_KEY
        return sanitizeStorageKey(stored)
    }

    private fun prefs(): SharedPreferences {
        return context.getSharedPreferences(PREFS_FILE, Context.MODE_PRIVATE)
    }

    companion object {
        private const val CHANNEL = "dev.rekan.native_theme_mode"

        /** Hardcoded plugin preferences file. Host apps never need to open this. */
        private const val PREFS_FILE = "native_theme_mode"

        private const val META_STORAGE_KEY = "storage_key"
        private const val META_DEFAULT_MODE = "default_mode"
        private const val META_PERSIST = "persist"
        private const val META_ENABLE_ANDROID = "enable_android"
        private const val DEFAULT_DATA_KEY = "theme_mode"

        private const val MODE_LIGHT = "light"
        private const val MODE_DARK = "dark"
        private const val MODE_SYSTEM = "system"

        private val RESERVED_KEYS =
            setOf(
                META_STORAGE_KEY,
                META_DEFAULT_MODE,
                META_PERSIST,
                META_ENABLE_ANDROID
            )

        internal fun sanitizeStorageKey(key: String): String {
            return if (key.isEmpty() || key in RESERVED_KEYS) {
                DEFAULT_DATA_KEY
            } else {
                key
            }
        }

        internal fun sanitizeMode(mode: String?): String {
            return when (mode) {
                MODE_LIGHT, MODE_DARK, MODE_SYSTEM -> mode
                else -> MODE_SYSTEM
            }
        }
    }
}

private fun MethodCall.argumentsMap(): Map<String, Any?> {
    val raw = arguments
    if (raw is Map<*, *>) {
        val out = HashMap<String, Any?>()
        for ((key, value) in raw) {
            if (key is String) {
                out[key] = value
            }
        }
        return out
    }
    return emptyMap()
}

private fun Map<String, Any?>.stringArg(key: String): String? {
    val value = this[key]
    return value as? String
}

private fun Map<String, Any?>.boolArg(key: String): Boolean? {
    val value = this[key]
    return value as? Boolean
}
