package app.charon.charon

import android.os.Handler
import android.os.Looper
import java.lang.reflect.InvocationHandler
import java.lang.reflect.Proxy

interface NativeHostCallbacks {
    fun establishTun(
        mtu: Int,
        ipv4Cidr: String,
        dnsCsv: String,
        routesCsv: String,
        allowedAppsCsv: String,
        disallowedAppsCsv: String,
    ): Int

    fun closeTun()
    fun protectSocket(fd: Int): Boolean
    fun updateNotification(
        state: String,
        title: String,
        subtitle: String,
        collapsed: String,
        publicLine: String,
        level: String,
        showRelease: Boolean,
        showRetry: Boolean,
    )

    fun updateTile(active: Boolean, subtitle: String)
    fun reportFatalError(code: String, detail: String)
}

/**
 * GoCoreBridge wraps the gomobile-generated `app.charon.bridge.CoreBridge`
 * from `charoncore.aar` (built by `v2/platform/android/build-aar.ps1`).
 *
 * Per docs/charon_ipc_contract.md section 3 ("Android"):
 * - Kotlin never parses protobuf messages; it only relays ByteArray envelopes.
 * - Callbacks from Go arrive on Go threads and are posted onto the Android main
 *   looper before touching UI, NotificationManager, or TileService APIs.
 */
class GoCoreBridge(
    private val dataDir: String,
    private val host: NativeHostCallbacks,
    private val serviceVersion: String = "0.1.0",
    private val xrayVersion: String = "25.10.15",
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var nativeBridge: Any? = null

    @Volatile
    private var eventListener: ((ByteArray) -> Unit)? = null

    init {
        initNativeBridge()
    }

    private fun initNativeBridge() {
        try {
            val bridgeFactoryCls = Class.forName("app.charon.bridge.Bridge")
            val nativeHostIface = Class.forName("app.charon.bridge.NativeHost")
            val eventSinkIface = Class.forName("app.charon.bridge.EventSink")

            val hostProxy = Proxy.newProxyInstance(
                nativeHostIface.classLoader,
                arrayOf(nativeHostIface),
                InvocationHandler { _, method, args ->
                    when (method.name) {
                        "establishTun" -> {
                            val mtu = (args[0] as Number).toInt()
                            val cidr = args[1] as String
                            val dns = args[2] as String
                            val routes = args[3] as String
                            val allowed = args[4] as String
                            val disallowed = args[5] as String
                            host.establishTun(mtu, cidr, dns, routes, allowed, disallowed).toLong()
                        }
                        "closeTun" -> {
                            host.closeTun()
                            null
                        }
                        "protectSocket" -> {
                            val fd = (args[0] as Number).toInt()
                            host.protectSocket(fd)
                        }
                        "updateNotification" -> {
                            val state = args[0] as String
                            val title = args[1] as String
                            val subtitle = args[2] as String
                            val collapsed = args[3] as String
                            val publicLine = args[4] as String
                            val level = args[5] as String
                            val showRelease = args[6] as Boolean
                            val showRetry = args[7] as Boolean
                            mainHandler.post {
                                host.updateNotification(
                                    state, title, subtitle, collapsed, publicLine, level, showRelease, showRetry
                                )
                            }
                            null
                        }
                        "updateTile" -> {
                            val active = args[0] as Boolean
                            val subtitle = args[1] as String
                            mainHandler.post { host.updateTile(active, subtitle) }
                            null
                        }
                        "reportFatalError" -> {
                            val code = args[0] as String
                            val detail = args[1] as String
                            mainHandler.post { host.reportFatalError(code, detail) }
                            null
                        }
                        else -> null
                    }
                }
            )

            val sinkProxy = Proxy.newProxyInstance(
                eventSinkIface.classLoader,
                arrayOf(eventSinkIface),
                InvocationHandler { _, method, args ->
                    if (method.name == "onEvent" && args != null && args.isNotEmpty()) {
                        val bytes = args[0] as? ByteArray
                        if (bytes != null) {
                            mainHandler.post { eventListener?.invoke(bytes) }
                        }
                    }
                    null
                }
            )

            val newCoreMethod = bridgeFactoryCls.getMethod(
                "newCoreBridge",
                String::class.java,
                nativeHostIface,
                String::class.java,
                String::class.java,
            )
            val inst = newCoreMethod.invoke(null, dataDir, hostProxy, serviceVersion, xrayVersion)
            val setSinkMethod = inst.javaClass.getMethod("setEventSink", eventSinkIface)
            setSinkMethod.invoke(inst, sinkProxy)
            nativeBridge = inst
        } catch (_: ClassNotFoundException) {
            // charoncore.aar is built by v2/platform/android/build-aar.ps1 and not committed to git.
            nativeBridge = null
        } catch (t: Throwable) {
            host.reportFatalError("BRIDGE_INIT_FAILED", t.message ?: "unknown")
        }
    }

    fun setEventListener(listener: ((ByteArray) -> Unit)?) {
        eventListener = listener
    }

    fun start(alwaysOnBoot: Boolean) {
        val inst = nativeBridge ?: return
        try {
            val m = inst.javaClass.getMethod("start", Boolean::class.javaPrimitiveType)
            m.invoke(inst, alwaysOnBoot)
        } catch (t: Throwable) {
            host.reportFatalError("BRIDGE_START_FAILED", t.message ?: "unknown")
        }
    }

    fun stop() {
        val inst = nativeBridge ?: return
        try {
            val m = inst.javaClass.getMethod("stop")
            m.invoke(inst)
        } catch (_: Throwable) {
        }
    }

    fun send(reqBytes: ByteArray): ByteArray {
        val inst = nativeBridge
            ?: throw IllegalStateException("charoncore.aar not loaded; run v2/platform/android/build-aar.ps1")
        val m = inst.javaClass.getMethod("send", ByteArray::class.java)
        return m.invoke(inst, reqBytes) as ByteArray
    }

    fun onVpnRevoked() {
        invokeVoid("onVpnRevoked")
    }

    fun onAnotherVpnTookOver() {
        invokeVoid("onAnotherVpnTookOver")
    }

    fun onAndroidStopped() {
        invokeVoid("onAndroidStopped")
    }

    fun onNetworkChanged() {
        invokeVoid("onNetworkChanged")
    }

    fun onWake() {
        invokeVoid("onWake")
    }

    fun onTileTapped(): String {
        val inst = nativeBridge ?: return "open_servers"
        return try {
            val m = inst.javaClass.getMethod("onTileTapped")
            (m.invoke(inst) as? String) ?: "open_servers"
        } catch (_: Throwable) {
            "open_servers"
        }
    }

    fun onNotificationAction(action: String) {
        val inst = nativeBridge ?: return
        try {
            val m = inst.javaClass.getMethod("onNotificationAction", String::class.java)
            m.invoke(inst, action)
        } catch (_: Throwable) {
        }
    }

    private fun invokeVoid(name: String) {
        val inst = nativeBridge ?: return
        try {
            val m = inst.javaClass.getMethod(name)
            m.invoke(inst)
        } catch (_: Throwable) {
        }
    }
}
