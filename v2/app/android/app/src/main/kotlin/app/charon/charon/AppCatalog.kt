package app.charon.charon

import android.content.Context
import android.content.pm.ApplicationInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import java.io.ByteArrayOutputStream
import java.util.Locale

/**
 * The installed apps for the split tunnel picker. Names and flags in one call, icons one at
 * a time (a list of hundreds of icons would be slow and heavy). Needs QUERY_ALL_PACKAGES.
 * Charon itself is left out: the UI never offers it.
 */
class AppCatalog(private val context: Context) {

    /** name, package, system. Updated system apps (a preinstalled browser) count as normal apps. */
    fun list(): List<Map<String, Any>> {
        val pm = context.packageManager
        return pm.getInstalledApplications(0)
            .filter { it.packageName != context.packageName }
            .map {
                val system = (it.flags and ApplicationInfo.FLAG_SYSTEM) != 0 &&
                    (it.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) == 0
                mapOf(
                    "package" to it.packageName,
                    "name" to it.loadLabel(pm).toString(),
                    "system" to system,
                )
            }
            .sortedBy { (it["name"] as String).lowercase(Locale.ROOT) }
    }

    /** A 96 px PNG of the app icon, or null when the app is gone or has none. */
    fun icon(packageName: String): ByteArray? = try {
        val drawable = context.packageManager.getApplicationIcon(packageName)
        val size = 96
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(Canvas(bitmap))
        ByteArrayOutputStream().also { bitmap.compress(Bitmap.CompressFormat.PNG, 100, it) }.toByteArray()
    } catch (_: Exception) {
        null
    }
}
