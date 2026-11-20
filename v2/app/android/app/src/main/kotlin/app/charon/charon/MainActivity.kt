package app.charon.charon

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

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
        private const val REQUEST_NOTIFICATIONS = 4002
    }

    private var pendingVpnResult: MethodChannel.Result? = null
    private var pendingNotificationsResult: MethodChannel.Result? = null

    private val catalog by lazy { AppCatalog(this) }
    private val appWork = Executors.newSingleThreadExecutor()

    private fun <T> inBackground(result: MethodChannel.Result, work: AppCatalog.() -> T) {
        appWork.execute {
            try {
                val value = catalog.work()
                runOnUiThread { result.success(value) }
            } catch (t: Throwable) {
                runOnUiThread { result.error("APPS_FAILED", t.message ?: "apps failed", null) }
            }
        }
    }

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
                        android.util.Log.e("CharonCore", "send failed", t)
                        result.error("CORE_SEND_FAILED", t.message ?: "send failed", null)
                    }
                }

                "prepareVpn" -> {
                    val prepIntent = VpnService.prepare(this)
                    if (prepIntent == null) {
                        startVpnServiceIfNeeded()
                        whenServiceUp { result.success(true) }
                    } else {
                        pendingVpnResult = result
                        @Suppress("DEPRECATION")
                        startActivityForResult(prepIntent, REQUEST_VPN_PERMISSION)
                    }
                }

                // Where the window keeps its own small files (ui_prefs.dart).
                "filesDir" -> result.success(filesDir.absolutePath)

                // Android 13 and newer ask at runtime. Older versions have no such prompt.
                "requestNotifications" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                        checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                    ) {
                        result.success(true)
                    } else {
                        pendingNotificationsResult?.success(false)
                        pendingNotificationsResult = result
                        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_NOTIFICATIONS)
                    }
                }

                // The split tunnel app picker. Off the main thread: hundreds of labels and icons.
                "listApps" -> inBackground(result) { list() }
                "appIcon" -> {
                    val pkg = call.arguments as? String
                    if (pkg == null) result.error("INVALID_ARGUMENT", "Missing package name", null)
                    else inBackground(result) { icon(pkg) }
                }

                "vpnLockdown" -> {
                    val (alwaysOn, lockdown) = CharonVpnService.systemFlags(this)
                    result.success(mapOf("alwaysOn" to alwaysOn, "lockdown" to lockdown))
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

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == REQUEST_NOTIFICATIONS) {
            val res = pendingNotificationsResult
            pendingNotificationsResult = null
            res?.success(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_VPN_PERMISSION) {
            val res = pendingVpnResult
            pendingVpnResult = null
            val granted = resultCode == Activity.RESULT_OK
            if (granted) {
                startVpnServiceIfNeeded()
                whenServiceUp { res?.success(true) }
            } else {
                CharonVpnService.ensureBridge(this).onVpnRevoked()
                res?.success(false)
            }
            return
        }
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    /**
     * startForegroundService is asynchronous, and Go asks for the TUN as soon as it
     * gets Connect. So the permission call only answers once the service object
     * exists (at most 3 seconds), otherwise the first Connect fails with
     * "could not create its network adapter".
     */
    private fun whenServiceUp(triesLeft: Int = 60, done: () -> Unit) {
        if (CharonVpnService.activeInstance != null || triesLeft <= 0) {
            done()
            return
        }
        Handler(Looper.getMainLooper()).postDelayed({ whenServiceUp(triesLeft - 1, done) }, 50)
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
