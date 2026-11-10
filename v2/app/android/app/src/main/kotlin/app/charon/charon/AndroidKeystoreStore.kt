package app.charon.charon

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.StandardCharsets
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Hardware-backed Android Keystore handler for `MethodChannel("app.charon/secure_storage")`
 * backing `KeystoreTokenStore` in `v2/app/lib/sync/token_store.dart` (SYNC3, V8).
 *
 * Encrypts device bearer tokens with AES-256-GCM using a non-exportable key in
 * `AndroidKeyStore`.
 */
class AndroidKeystoreStore(context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
        private const val KEY_ALIAS = "app.charon.sync.token_master_key"
        private const val PREFS_NAME = "charon_keystore_tokens"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_TAG_BITS = 128
    }

    private val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        if (key.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "Missing key argument", null)
            return
        }
        try {
            when (call.method) {
                "read" -> {
                    result.success(readSecret(key))
                }
                "write" -> {
                    val value = call.argument<String>("value") ?: ""
                    writeSecret(key, value)
                    result.success(null)
                }
                "delete" -> {
                    prefs.edit().remove(key).apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("KEYSTORE_ERROR", "Secure storage operation failed", null)
        }
    }

    private fun getOrCreateSecretKey(): SecretKey {
        val ks = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        val existing = ks.getEntry(KEY_ALIAS, null) as? KeyStore.SecretKeyEntry
        if (existing != null) {
            return existing.secretKey
        }
        val keyGen = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        val spec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .build()
        keyGen.init(spec)
        return keyGen.generateKey()
    }

    private fun writeSecret(key: String, plaintext: String) {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getOrCreateSecretKey())
        val iv = cipher.iv
        val ct = cipher.doFinal(plaintext.toByteArray(StandardCharsets.UTF_8))

        val combined = ByteArray(1 + iv.size + ct.size)
        combined[0] = iv.size.toByte()
        System.arraycopy(iv, 0, combined, 1, iv.size)
        System.arraycopy(ct, 0, combined, 1 + iv.size, ct.size)

        val encoded = Base64.encodeToString(combined, Base64.NO_WRAP)
        prefs.edit().putString(key, encoded).apply()
    }

    private fun readSecret(key: String): String? {
        val encoded = prefs.getString(key, null) ?: return null
        val combined = Base64.decode(encoded, Base64.NO_WRAP)
        if (combined.size < 2) return null
        val ivLen = combined[0].toInt() and 0xFF
        if (combined.size <= 1 + ivLen) return null

        val iv = combined.copyOfRange(1, 1 + ivLen)
        val ct = combined.copyOfRange(1 + ivLen, combined.size)

        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, getOrCreateSecretKey(), GCMParameterSpec(GCM_TAG_BITS, iv))
        val pt = cipher.doFinal(ct)
        return String(pt, StandardCharsets.UTF_8)
    }
}
