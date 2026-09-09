package com.druvatara.guardian.identity

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.provider.Settings.Secure
import android.util.Base64
import android.util.Log
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.SecureRandom
import java.util.UUID

class DeviceIdentityManager(private val context: Context) {
    private val TAG = "DeviceIdentityManager"
    private val prefs: SharedPreferences = context.getSharedPreferences("device_identity", Context.MODE_PRIVATE)
    private val gson = Gson()

    companion object {
        private const val KEY_INSTALLATION_ID = "installation_id"
        private const val KEY_DEVICE_UUID = "device_uuid"
        private const val KEY_KEY_PAIR = "key_pair"
        private const val KEY_CREDENTIAL_VERSION = "credential_version"
        private const val KEY_PUBLIC_KEY = "public_key"
        private const val KEY_PRIVATE_KEY = "private_key"
    }

    data class DeviceIdentity(
        val installationId: String,
        val deviceUuid: String,
        val keyPair: KeyPair?,
        val credentialVersion: Int = 1,
        val publicKey: String,
        val privateKey: String,
    )

    suspend fun initialize() = withContext(Dispatchers.IO) {
        var identity = loadIdentity()
        if (identity == null) {
            identity = generateNewIdentity()
            saveIdentity(identity)
        }
        Log.d(TAG, "Device identity initialized: ${identity.deviceUuid}")
    }

    private fun loadIdentity(): DeviceIdentity? {
        val installationId = prefs.getString(KEY_INSTALLATION_ID, null)
        val deviceUuid = prefs.getString(KEY_DEVICE_UUID, null)
        val credentialVersion = prefs.getInt(KEY_CREDENTIAL_VERSION, 0)
        val publicKey = prefs.getString(KEY_PUBLIC_KEY, null)
        val privateKey = prefs.getString(KEY_PRIVATE_KEY, null)

        if (installationId != null && deviceUuid != null && publicKey != null && privateKey != null) {
            return DeviceIdentity(
                installationId = installationId,
                deviceUuid = deviceUuid,
                keyPair = null, // We don't store the actual KeyPair object
                credentialVersion = credentialVersion,
                publicKey = publicKey,
                privateKey = privateKey,
            )
        }
        return null
    }

    private fun generateNewIdentity(): DeviceIdentity {
        val installationId = UUID.randomUUID().toString().replace("-", "")
        val deviceUuid = generateDeviceUuid()
        val keyPair = generateKeyPair()
        val credentialVersion = 1

        return DeviceIdentity(
            installationId = installationId,
            deviceUuid = deviceUuid,
            keyPair = keyPair,
            credentialVersion = credentialVersion,
            publicKey = Base64.encodeToString(keyPair.public.encoded, Base64.NO_WRAP),
            privateKey = Base64.encodeToString(keyPair.private.encoded, Base64.NO_WRAP),
        )
    }

    private fun generateDeviceUuid(): String {
        // Use Android ID as base, but add randomness for privacy
        val androidId = Secure.getString(context.contentResolver, Secure.ANDROID_ID) ?: "unknown"
        val random = SecureRandom().generateSeed(8)
        return (androidId + bytesToHex(random)).substring(0, 32)
    }

    private fun generateKeyPair(): KeyPair {
        val keyPairGenerator = KeyPairGenerator.getInstance("RSA")
        keyPairGenerator.initialize(2048)
        return keyPairGenerator.generateKeyPair()
    }

    private fun saveIdentity(identity: DeviceIdentity) {
        prefs.edit()
            .putString(KEY_INSTALLATION_ID, identity.installationId)
            .putString(KEY_DEVICE_UUID, identity.deviceUuid)
            .putInt(KEY_CREDENTIAL_VERSION, identity.credentialVersion)
            .putString(KEY_PUBLIC_KEY, identity.publicKey)
            .putString(KEY_PRIVATE_KEY, identity.privateKey)
            .apply()
    }

    fun getInstallationId(): String = prefs.getString(KEY_INSTALLATION_ID, "") ?: ""
    fun getDeviceUuid(): String = prefs.getString(KEY_DEVICE_UUID, "") ?: ""
    fun getPublicKey(): String = prefs.getString(KEY_PUBLIC_KEY, "") ?: ""
    fun getPrivateKey(): String = prefs.getString(KEY_PRIVATE_KEY, "") ?: ""
    fun getCredentialVersion(): Int = prefs.getInt(KEY_CREDENTIAL_VERSION, 1)

    fun rotateCredentials(): DeviceIdentity {
        val newKeyPair = generateKeyPair()
        val newCredentialVersion = getCredentialVersion() + 1

        val identity = DeviceIdentity(
            installationId = getInstallationId(),
            deviceUuid = getDeviceUuid(),
            keyPair = newKeyPair,
            credentialVersion = newCredentialVersion,
            publicKey = Base64.encodeToString(newKeyPair.public.encoded, Base64.NO_WRAP),
            privateKey = Base64.encodeToString(newKeyPair.private.encoded, Base64.NO_WRAP),
        )

        saveIdentity(identity)
        Log.d(TAG, "Credentials rotated to version $newCredentialVersion")
        return identity
    }

    fun revokeCredentials() {
        prefs.edit().clear().apply()
        Log.d(TAG, "Credentials revoked")
    }

    private fun bytesToHex(bytes: ByteArray): String {
        return bytes.joinToString("") { "%02x".format(it) }
    }
}