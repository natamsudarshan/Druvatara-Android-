package com.druvatara.guardian.sync

import android.content.Context
import android.util.Log
import com.druvatara.guardian.event_queue.EventQueue
import com.druvatara.guardian.engine.GuardianEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class SyncEngine(
    private val context: Context,
    private val scope: CoroutineScope,
) {
    private val TAG = "SyncEngine"
    private val httpClient = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()
    private var lastSyncTime = 0L
    private var isSyncing = false
    private val baseUrl = "https://api.druvatara.com/api/v1"
    private var deviceCredentials: DeviceCredentials? = null

    data class DeviceCredentials(
        val deviceId: String,
        val accessToken: String,
        val familyId: String,
        val childId: String,
    )

    suspend fun startSync() = withContext(Dispatchers.IO) {
        // Load credentials and start periodic sync
        loadCredentials()
        performSync()
    }

    private fun loadCredentials() {
        // Load from secure storage
        deviceCredentials = DeviceCredentials(
            deviceId = "dev_placeholder",
            accessToken = "token_placeholder",
            familyId = "fam_placeholder",
            childId = "child_placeholder",
        )
    }

    suspend fun performSync() = withContext(Dispatchers.IO) {
        if (isSyncing || deviceCredentials == null) return@withContext
        isSyncing = true

        try {
            // Send pending events
            sendPendingEvents()

            // Request policy updates
            requestPolicyUpdate()

            // Send health status
            sendHealthStatus()

            lastSyncTime = System.currentTimeMillis()
            Log.d(TAG, "Sync completed successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Sync failed", e)
        } finally {
            isSyncing = false
        }
    }

    private fun sendPendingEvents() {
        val eventQueue = EventQueue(context, scope)
        val events = eventQueue.getPendingEvents()
        if (events.isEmpty()) return

        val credentials = deviceCredentials!!
        val json = JSONObject().apply {
            put("deviceId", credentials.deviceId)
            put("familyId", credentials.familyId)
            put("childId", credentials.childId)
            put("events", events.map { event ->
                JSONObject().apply {
                    put("eventId", event.eventId)
                    put("eventType", event.eventType)
                    put("eventVersion", event.eventVersion)
                    put("capturedAt", event.capturedAt)
                    put("payload", JSONObject(event.payload))
                    put("signature", event.signature)
                }
            })
        }

        val request = Request.Builder()
            .url("$baseUrl/device-events/batch")
            .addHeader("Authorization", "Device ${credentials.accessToken}")
            .post(json.toString().toRequestBody("application/json".toMediaType()))
            .build()

        httpClient.newCall(request).execute().use { response ->
            if (response.isSuccessful) {
                Log.d(TAG, "Sent ${events.size} events")
            } else {
                Log.w(TAG, "Failed to send events: ${response.code}")
            }
        }
    }

    private fun requestPolicyUpdate() {
        val credentials = deviceCredentials!!
        val request = Request.Builder()
            .url("$baseUrl/device/policies/${credentials.childId}?deviceId=${credentials.deviceId}")
            .addHeader("Authorization", "Device ${credentials.accessToken}")
            .get()
            .build()

        httpClient.newCall(request).execute().use { response ->
            if (response.isSuccessful) {
                val policyJson = response.body?.string()
                if (policyJson != null) {
                    GuardianEngine.getInstance()?.onPolicyUpdated(policyJson)
                }
            } else if (response.code != 304) { // 304 Not Modified
                Log.w(TAG, "Policy sync failed: ${response.code}")
            }
        }
    }

    private fun sendHealthStatus() {
        val credentials = deviceCredentials!!
        val health = GuardianEngine.getInstance()?.getProtectionStatus()
        val healthJson = JSONObject().apply {
            put("deviceId", credentials.deviceId)
            put("familyId", credentials.familyId)
            put("childId", credentials.childId)
            put("appVersion", "1.0.0")
            put("policyVersion", health?.policyVersion ?: 0)
            put("backendConnected", health?.isProtected == true)
            put("vpnActive", health?.vpnActive == true)
            put("usageAccess", health?.usageAccessGranted == true)
            put("locationPerm", health?.locationPermissionGranted == true)
            put("backgroundLoc", false)
            put("notificationPerm", health?.notificationPermissionGranted == true)
            put("backgroundService", true)
            put("batteryOptimized", false)
        }

        val request = Request.Builder()
            .url("$baseUrl/device/health")
            .addHeader("Authorization", "Device ${credentials.accessToken}")
            .post(healthJson.toString().toRequestBody("application/json".toMediaType()))
            .build()

        httpClient.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                Log.w(TAG, "Health sync failed: ${response.code}")
            }
        }
    }

    fun getLastSyncTime(): Long = lastSyncTime

    fun forceSync(scope: CoroutineScope) {
        scope.launch(Dispatchers.IO) { performSync() }
    }
}