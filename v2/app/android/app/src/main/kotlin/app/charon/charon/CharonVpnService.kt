package app.charon.charon

import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.service.quicksettings.TileService

/**
 * Foreground Android VpnService that hosts the shared Go charon core (CORE1-CORE6).
 *
 * - Keeps the Go core alive in the foreground service process even when the
 *   Flutter Activity is closed.
 * - Establishes the TUN file descriptor with per-app and CIDR split tunnel rules
 *   and keeps the TUN interface open while Held so traffic cannot leak direct (CORE3).
 * - Protects Xray's outgoing sockets through VpnService.protect(fd) so updates
 *   can still traverse the tunnel (CORE4, V11).
 * - Resumes on boot only when Android's Always-on VPN starts the service (CORE6).
 */
class CharonVpnService : VpnService(), NativeHostCallbacks {

    companion object {
        const val ACTION_START = "app.charon.action.START"
        const val ACTION_DISCONNECT = "app.charon.action.DISCONNECT"
        const val ACTION_CANCEL = "app.charon.action.CANCEL"
        const val ACTION_RELEASE = "app.charon.action.RELEASE"
        const val ACTION_RETRY_NOW = "app.charon.action.RETRY_NOW"
        const val ACTION_SWITCH_NOW = "app.charon.action.SWITCH_NOW"

        @Volatile
        var activeInstance: CharonVpnService? = null
            private set

        @Volatile
        private var sharedBridge: GoCoreBridge? = null

        @Volatile
        var tileActive: Boolean = false
            private set

        @Volatile
        var tileSubtitle: String = "Off"
            private set

        private const val PREFS = "charon_android"
        private const val KEY_ALWAYS_ON = "system_always_on"
        private const val KEY_LOCKDOWN = "system_lockdown"

        /**
         * Whether Android's Always-on VPN and "Block connections without VPN" are
         * on for Charon. Only a running VpnService can ask the system (API 29), so
         * when none runs the answer is the last one it saw. The system rebinds the
         * service whenever the user changes these switches, so that value stays
         * close to the truth.
         */
        fun systemFlags(context: Context): Pair<Boolean, Boolean> {
            activeInstance?.recordSystemFlags()
            val p = context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            return Pair(p.getBoolean(KEY_ALWAYS_ON, false), p.getBoolean(KEY_LOCKDOWN, false))
        }

        @Synchronized
        fun ensureBridge(context: Context): GoCoreBridge {
            var b = sharedBridge
            if (b == null) {
                val appCtx = context.applicationContext
                val host = activeInstance ?: HeadlessNativeHost(appCtx)
                b = GoCoreBridge(appCtx.filesDir.absolutePath, host)
                b.start(false)
                sharedBridge = b
            }
            return b
        }
    }

    private var tunPfd: ParcelFileDescriptor? = null

    /** True between startForeground and stopForeground, so onStartCommand never overwrites a real notification. */
    @Volatile
    private var isForeground = false
    private var connectivityManager: ConnectivityManager? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun onCreate() {
        super.onCreate()
        activeInstance = this
        recordSystemFlags()
        CharonNotificationHelper.ensureChannels(this)
        registerNetworkCallback()
    }

    private fun recordSystemFlags() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return
        getSharedPreferences(PREFS, MODE_PRIVATE).edit()
            .putBoolean(KEY_ALWAYS_ON, isAlwaysOn)
            .putBoolean(KEY_LOCKDOWN, isLockdownEnabled)
            .apply()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        recordSystemFlags()
        // startForegroundService() obliges us to call startForeground() within seconds, also
        // while the core is idle and no notification should stay. Enter and leave at once.
        if (!isForeground) {
            enterForeground(
                CharonNotificationHelper.buildForegroundNotification(
                    this, "idle", "Charon", "", "", "Charon", "idle", false, false,
                )
            )
            stopForeground(STOP_FOREGROUND_REMOVE)
            isForeground = false
        }
        val bridge = ensureBridge(this)
        val action = intent?.action

        // CORE6: Android boot resumes only when the system Always-on VPN starts it.
        val isSystemAlwaysOn = action == SERVICE_INTERFACE ||
            (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && isAlwaysOn)

        if (isSystemAlwaysOn) {
            bridge.start(true)
        } else {
            when (action) {
                ACTION_DISCONNECT -> bridge.onNotificationAction("disconnect")
                ACTION_CANCEL -> bridge.onNotificationAction("cancel")
                ACTION_RELEASE -> bridge.onNotificationAction("release")
                ACTION_RETRY_NOW -> bridge.onNotificationAction("retry_now")
                ACTION_SWITCH_NOW -> bridge.onNotificationAction("switch_now")
            }
        }
        return START_STICKY
    }

    override fun onRevoke() {
        val b = sharedBridge
        // Distinguish permission removal from another VPN taking the slot.
        if (prepare(this) != null) {
            b?.onVpnRevoked()
        } else {
            b?.onAnotherVpnTookOver()
        }
        closeTun()
        stopForeground(STOP_FOREGROUND_DETACH)
        stopSelf()
        super.onRevoke()
    }

    override fun onDestroy() {
        unregisterNetworkCallback()
        closeTun()
        if (activeInstance === this) {
            activeInstance = null
        }
        super.onDestroy()
    }

    override fun establishTun(
        mtu: Int,
        ipv4Cidr: String,
        dnsCsv: String,
        routesCsv: String,
        allowedAppsCsv: String,
        disallowedAppsCsv: String,
    ): Int {
        closeTun()

        val builder = Builder()
            .setSession("Charon")
            .setMtu(if (mtu > 0) mtu else 1500)

        val cidrParts = ipv4Cidr.split("/")
        val addr = cidrParts.getOrNull(0)?.trim().takeUnless { it.isNullOrEmpty() } ?: "10.255.0.2"
        val prefix = cidrParts.getOrNull(1)?.trim()?.toIntOrNull() ?: 30
        builder.addAddress(addr, prefix)

        dnsCsv.split(",").map { it.trim() }.filter { it.isNotEmpty() }.forEach { dns ->
            runCatching { builder.addDnsServer(dns) }
        }

        routesCsv.split(",").map { it.trim() }.filter { it.isNotEmpty() }.forEach { route ->
            val rp = route.split("/")
            val rIp = rp.getOrNull(0)?.trim() ?: return@forEach
            val rPrefix = rp.getOrNull(1)?.trim()?.toIntOrNull() ?: 32
            runCatching { builder.addRoute(rIp, rPrefix) }
        }

        val allowedApps = allowedAppsCsv.split(",").map { it.trim() }.filter { it.isNotEmpty() }
        val disallowedApps = disallowedAppsCsv.split(",").map { it.trim() }.filter { it.isNotEmpty() }

        if (allowedApps.isNotEmpty()) {
            allowedApps.forEach { pkg ->
                runCatching { builder.addAllowedApplication(pkg) }
            }
        } else {
            disallowedApps.forEach { pkg ->
                runCatching { builder.addDisallowedApplication(pkg) }
            }
        }

        val pfd = builder.establish()
            ?: throw IllegalStateException("VpnService.Builder.establish() returned null")
        tunPfd = pfd
        return pfd.fd
    }

    override fun closeTun() {
        try {
            tunPfd?.close()
        } catch (_: Throwable) {
        } finally {
            tunPfd = null
        }
    }

    override fun protectSocket(fd: Int): Boolean {
        return protect(fd)
    }

    override fun updateNotification(
        state: String,
        title: String,
        subtitle: String,
        collapsed: String,
        publicLine: String,
        level: String,
        showRelease: Boolean,
        showRetry: Boolean,
    ) {
        val notif = CharonNotificationHelper.buildForegroundNotification(
            this,
            state,
            title,
            subtitle,
            collapsed,
            publicLine,
            level,
            showRelease,
            showRetry,
        )
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (state == "idle") {
            stopForeground(STOP_FOREGROUND_REMOVE)
            isForeground = false
        } else if (state == "vpn revoked" || state == "another vpn") {
            stopForeground(STOP_FOREGROUND_DETACH)
            isForeground = false
            nm.notify(CharonNotificationHelper.NOTIFICATION_ID_FOREGROUND, notif)
        } else {
            enterForeground(notif)
        }
    }

    private fun enterForeground(notif: android.app.Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                CharonNotificationHelper.NOTIFICATION_ID_FOREGROUND,
                notif,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(CharonNotificationHelper.NOTIFICATION_ID_FOREGROUND, notif)
        }
        isForeground = true
    }

    override fun updateTile(active: Boolean, subtitle: String) {
        tileActive = active
        tileSubtitle = subtitle
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            runCatching {
                TileService.requestListeningState(
                    this,
                    ComponentName(this, CharonTileService::class.java)
                )
            }
        }
    }

    override fun reportFatalError(code: String, detail: String) {
        // Redacted by construction: detail contains only bridge error codes/messages, never secrets.
        android.util.Log.e("CharonVpnService", "Fatal bridge error [$code]: $detail")
    }

    private fun registerNetworkCallback() {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager ?: return
        connectivityManager = cm
        val req = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
            .build()
        val cb = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                sharedBridge?.onNetworkChanged()
            }

            override fun onLost(network: Network) {
                sharedBridge?.onNetworkChanged()
            }
        }
        networkCallback = cb
        runCatching { cm.registerNetworkCallback(req, cb) }
    }

    private fun unregisterNetworkCallback() {
        val cm = connectivityManager ?: return
        val cb = networkCallback ?: return
        runCatching { cm.unregisterNetworkCallback(cb) }
        networkCallback = null
    }

    private class HeadlessNativeHost(private val appContext: Context) : NativeHostCallbacks {
        override fun establishTun(
            mtu: Int,
            ipv4Cidr: String,
            dnsCsv: String,
            routesCsv: String,
            allowedAppsCsv: String,
            disallowedAppsCsv: String,
        ): Int {
            val svc = activeInstance
            if (svc != null) {
                return svc.establishTun(mtu, ipv4Cidr, dnsCsv, routesCsv, allowedAppsCsv, disallowedAppsCsv)
            }
            val intent = Intent(appContext, CharonVpnService::class.java).apply {
                action = ACTION_START
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                appContext.startForegroundService(intent)
            } else {
                appContext.startService(intent)
            }
            throw IllegalStateException("CharonVpnService starting; retry establishTun when bound")
        }

        override fun closeTun() {
            activeInstance?.closeTun()
        }

        override fun protectSocket(fd: Int): Boolean {
            return activeInstance?.protectSocket(fd) ?: false
        }

        override fun updateNotification(
            state: String,
            title: String,
            subtitle: String,
            collapsed: String,
            publicLine: String,
            level: String,
            showRelease: Boolean,
            showRetry: Boolean,
        ) {
            activeInstance?.updateNotification(
                state, title, subtitle, collapsed, publicLine, level, showRelease, showRetry
            )
        }

        override fun updateTile(active: Boolean, subtitle: String) {
            tileActive = active
            tileSubtitle = subtitle
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                runCatching {
                    TileService.requestListeningState(
                        appContext,
                        ComponentName(appContext, CharonTileService::class.java)
                    )
                }
            }
        }

        override fun reportFatalError(code: String, detail: String) {
            android.util.Log.e("CharonVpnService", "Fatal bridge error [$code]: $detail")
        }
    }
}
