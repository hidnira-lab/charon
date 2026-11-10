package app.charon.charon

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Builds Android foreground VPN notifications and usage alerts matching
 * NotifyAndroid.dc.html and CORE5:
 * - Ongoing foreground notification, low importance, no sound.
 * - Lock screen shows the public version only ("Connected", "Connecting",
 *   "Reconnecting", "Traffic held", "VPN is off"): no server name, no IP,
 *   no speeds until unlocked.
 * - While held without the UI, notification is red (#DC7C7D), says
 *   "Traffic held", and includes a Release action button (CORE5).
 * - Separate channel for usage alerts (once at 80% and once at cap).
 */
object CharonNotificationHelper {
    const val CHANNEL_VPN_STATUS = "charon_vpn_status"
    const val CHANNEL_USAGE_ALERTS = "charon_usage_alerts"
    const val NOTIFICATION_ID_FOREGROUND = 1001
    const val NOTIFICATION_ID_USAGE = 1002

    private const val COLOR_OK = 0xFF60A1D9.toInt()
    private const val COLOR_WARN = 0xFFE3B579.toInt()
    private const val COLOR_CRIT = 0xFFDC7C7D.toInt()
    private const val COLOR_IDLE = 0xFF8A8A8A.toInt()

    fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val statusChannel = NotificationChannel(
            CHANNEL_VPN_STATUS,
            "Tunnel status",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Ongoing Charon tunnel and kill switch status"
            setShowBadge(false)
            enableVibration(false)
            setSound(null, null)
        }

        val usageChannel = NotificationChannel(
            CHANNEL_USAGE_ALERTS,
            "Monthly traffic alerts",
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = "Alerts at 80% and 100% of a server's monthly quota"
        }

        nm.createNotificationChannel(statusChannel)
        nm.createNotificationChannel(usageChannel)
    }

    fun buildForegroundNotification(
        context: Context,
        state: String,
        title: String,
        subtitle: String,
        collapsed: String,
        publicLine: String,
        level: String,
        showRelease: Boolean,
        showRetry: Boolean,
    ): Notification {
        ensureChannels(context)

        val color = when (level) {
            "ok" -> COLOR_OK
            "warn" -> COLOR_WARN
            "crit" -> COLOR_CRIT
            else -> COLOR_IDLE
        }

        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPending = PendingIntent.getActivity(
            context,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Lock screen public version: no server name, no IP, no speeds.
        val publicBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_VPN_STATUS)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        val publicNotif = publicBuilder
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentTitle("Charon")
            .setContentText(publicLine)
            .setColor(color)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_VPN_STATUS)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }

        builder
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentTitle(title)
            .setContentText(collapsed.ifEmpty { subtitle })
            .setSubText(if (collapsed.isNotEmpty() && subtitle != collapsed) subtitle else null)
            .setContentIntent(openPending)
            .setOngoing(state != "idle" && state != "vpn revoked" && state != "another vpn")
            .setOnlyAlertOnce(true)
            .setColor(color)
            .setVisibility(Notification.VISIBILITY_PRIVATE)
            .setPublicVersion(publicNotif)

        if (state == "connected" || state == "on backup") {
            builder.setUsesChronometer(true)
            builder.setWhen(System.currentTimeMillis())
        }

        // Primary action button based on state (NotifyAndroid.dc.html).
        when (state) {
            "connected", "on backup" -> {
                builder.addAction(serviceAction(context, 1, "Disconnect", CharonVpnService.ACTION_DISCONNECT))
            }
            "verifying", "reconnecting", "switching" -> {
                builder.addAction(serviceAction(context, 2, "Cancel", CharonVpnService.ACTION_CANCEL))
            }
            "reconnecting held" -> {
                builder.addAction(serviceAction(context, 3, "Switch now", CharonVpnService.ACTION_SWITCH_NOW))
            }
            "blocked" -> {
                if (showRetry) {
                    builder.addAction(serviceAction(context, 4, "Retry now", CharonVpnService.ACTION_RETRY_NOW))
                }
            }
            "vpn revoked", "another vpn" -> {
                builder.addAction(
                    Notification.Action.Builder(
                        null,
                        if (state == "vpn revoked") "Allow again" else "Reconnect",
                        openPending
                    ).build()
                )
            }
        }

        if (showRelease) {
            builder.addAction(serviceAction(context, 5, "Release", CharonVpnService.ACTION_RELEASE))
        }

        return builder.build()
    }

    private fun serviceAction(
        context: Context,
        requestCode: Int,
        label: String,
        action: String,
    ): Notification.Action {
        val intent = Intent(context, CharonVpnService::class.java).apply {
            this.action = action
        }
        val pi = PendingIntent.getService(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return Notification.Action.Builder(null, label, pi).build()
    }
}
