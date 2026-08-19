package dev.rekan.native_theme_mode

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test
import kotlin.test.assertEquals

internal class NativeThemeModePluginTest {
    @Test
    fun sanitizeMode_mapsKnownValues() {
        assertEquals("light", NativeThemeModePlugin.sanitizeMode("light"))
        assertEquals("dark", NativeThemeModePlugin.sanitizeMode("dark"))
        assertEquals("system", NativeThemeModePlugin.sanitizeMode("system"))
        assertEquals("system", NativeThemeModePlugin.sanitizeMode(null))
        assertEquals("system", NativeThemeModePlugin.sanitizeMode("nope"))
    }

    @Test
    fun sanitizeStorageKey_rejectsReservedNames() {
        assertEquals("theme_mode", NativeThemeModePlugin.sanitizeStorageKey(""))
        assertEquals("theme_mode", NativeThemeModePlugin.sanitizeStorageKey("storage_key"))
        assertEquals("custom", NativeThemeModePlugin.sanitizeStorageKey("custom"))
    }

    @Test
    fun onMethodCall_unknown_returnsNotImplemented() {
        val plugin = NativeThemeModePlugin()
        val call = MethodCall("getPlatformVersion", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)
        Mockito.verify(mockResult).notImplemented()
    }
}
