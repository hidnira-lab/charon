package app.charon.charon

import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/**
 * Android Quick Settings tile matching QuickTileAndroid.dc.html:
 * - Android paints the tile; Charon sets active/inactive and writes the subtitle.
 * - When traffic is held by the kill switch, the tile stays ACTIVE and the
 *   subtitle says "Traffic held".
 * - Tap toggles connect/disconnect; tap while connecting cancels the attempt.
 * - On a locked phone, Android asks to unlock before Charon acts (unlockAndRun).
 */
class CharonTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        refreshTile()
    }

    override fun onClick() {
        super.onClick()
        unlockAndRun {
            handleTapUnlocked()
        }
    }

    private fun handleTapUnlocked() {
        // If VPN permission is not granted yet, open Charon so it can request permission.
        if (VpnService.prepare(this) != null) {
            openCharonApp()
            return
        }

        val bridge = CharonVpnService.ensureBridge(this)
        when (bridge.onTileTapped()) {
            "open_servers" -> openCharonApp()
            "connect" -> {
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
        refreshTile()
    }

    private fun refreshTile() {
        val tile = qsTile ?: return
        val needsPerm = VpnService.prepare(this) != null
        val active = !needsPerm && CharonVpnService.tileActive
        val sub = if (needsPerm) "Allow VPN" else CharonVpnService.tileSubtitle

        tile.state = if (active) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.label = "Charon"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = sub
        }
        tile.contentDescription = "Charon, $sub"
        tile.updateTile()
    }

    private fun openCharonApp() {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        @Suppress("DEPRECATION")
        startActivityAndCollapse(intent)
    }
}
