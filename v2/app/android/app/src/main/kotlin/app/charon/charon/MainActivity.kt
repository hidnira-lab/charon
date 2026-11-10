package app.charon.charon

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity relays raw protobuf Envelope byte arrays between Flutter and
 * the Go core in CharonVpnService over MethodChannel("app.charon/core") and
 * EventChannel("app.charon/core_events") without ever decoding protobuf in
 * Kotlin (IPC1).
 *
 * Also provides:
 * - "prepareVpn" to request Android VPN permission when needed.
 * - "openVpnSettings" to open system VPN settings for Always-on VPN (V12).
 * - MethodChannel("app.charon/secure_storage") backed by AndroidKeystoreStore (V8).
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_CORE = "app.charon/core"
        private const val CHANNEL_CORE_EVENTS = "app.charon/core_events"
        private const val CHANNEL_SECURE_STORAGE = "app.charon/secure_storage"
        private const val REQUEST_VPN_PERMISSION = 4001
    }

    private var pendingVpnResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val bridge = CharonVpnService.ensureBridge(this)

        MethodChannel(messenger, CHANNEL_SECURE_STORAGE)
            .setMethodCallHandler(AndroidKeystoreStore(this))

        EventChannel(messenger, CHANNEL_CORE_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    bridge.setEventListener { bytes ->
                        events?.success(bytes)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    bridge.setEventListener(null)
                }
            }
        )

        MethodChannel(messenger, CHANNEL_CORE).setMethodCallHandler { call, result ->
            when (call.method) {
                "send" -> {
                    val reqBytes = call.arguments as? ByteArray
                        ?: call.argument<ByteArray>("bytes")
                    if (reqBytes == null) {
                        result.error("INVALID_ARGUMENT", "Missing Envelope byte array", null)
                        return@setMethodCallHandler
                    }
                    try {
                        startVpnServiceIfNeeded()
                        val respBytes = bridge.send(reqBytes)
                        result.success(respBytes)
                    } catch (t: Throwable) {
                        result.error("CORE_SEND_FAILED", t.message ?: "send failed", null)
                    }
                }

                "prepareVpn" -> {
                    val prepIntent = VpnService.prepare(this)
                    if (prepIntent == null) {
                        startVpnServiceIfNeeded()
                        result.success(true)
                    } else {
                        pendingVpnResult = result
                        @Suppress("DEPRECATION")
                        startActivityForResult(prepIntent, REQUEST_VPN_PERMISSION)
                    }
                }

                "openVpnSettings" -> {
                    val intent = Intent(Settings.ACTION_VPN_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    val resolved = runCatching {
                        startActivity(intent)
                        true
                    }.getOrElse {
                        runCatching {
                            startActivity(Intent(Settings.ACTION_WIRELESS_SETTINGS))
                            true
                        }.getOrDefault(false)
                    }
                    result.success(resolved)
                }

                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_VPN_PERMISSION) {
            val res = pendingVpnResult
            pendingVpnResult = null
            val granted = resultCode == Activity.RESULT_OK
            if (granted) {
                startVpnServiceIfNeeded()
            } else {
                CharonVpnService.ensureBridge(this).onVpnRevoked()
            }
            res?.success(granted)
            return
        }
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun startVpnServiceIfNeeded() {
        if (VpnService.prepare(this) != null) return
        val svcIntent = Intent(this, CharonVpnService::class.java).apply {
            action = CharonVpnService.ACTION_START
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(svcIntent)
        } else {
            startService(svcIntent)
        }
    }
}
