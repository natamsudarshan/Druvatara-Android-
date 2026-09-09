package com.druvatara.guardian.device_health

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import com.druvatara.guardian.permission.PermissionManager
import com.druvatara.guardian.vpn.VpnFilterEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class DeviceHealthEngine(
    private val context: Context,
    private val scope: CoroutineScope,
) {
    private val TAG = "DeviceHealthEngine"
    private var isMonitoring = false
    private var lastHealthCheck = 0L
    private var currentHealth = DeviceHealth()

    data class DeviceHealth(
        val backendConnected: Boolean = false,
        val authValid: Boolean = false,
        val usageAccess: Boolean = false,
        val vpnActive: Boolean = false,
        val locationPerm: Boolean = false,
        val backgroundLoc: Boolean = false,
        val notificationPerm: Boolean = false,
        val backgroundService: Boolean = false,
        val batteryOptimized: Boolean = false,
        val appVersion: String = "",
        val policyVersion: Int = 0,
        val batteryLevel: Int = 100,
        val networkType: String = "UNKNOWN",
        val manufacturer: String = Build.MANUFACTURER,
        val osVersion: String = Build.VERSION.RELEASE,
        val checkedAt: Long = System.currentTimeMillis(),
    )

    suspend fun startHealthMonitoring() = withContext(Dispatchers.IO) {
        isMonitoring = true
        while (isMonitoring) {
            try {
                currentHealth = performHealthCheck()
                lastHealthCheck = System.currentTimeMillis()
                Log.d(TAG, "Health check: $currentHealth")
            } catch (e: Exception) {
                Log.e(TAG, "Health check failed", e)
            }
            try {
                kotlinx.coroutines.delay(5 * 60 * 1000) // 5 minutes
            } catch (e: InterruptedException) {
                break
            }
        }
    }

    private fun performHealthCheck(): DeviceHealth {
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = connectivityManager.activeNetwork
        val networkCapabilities = network?.let { connectivityManager.getNetworkCapabilities(it) }

        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryLevel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, 100) ?: 100
        }

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val isBatteryOptimized = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            powerManager.isIgnoringBatteryOptimizations(context.packageName)
        } else false

        val networkType = when {
            networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true -> "WIFI"
            networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true -> "CELLULAR"
            networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) == true -> "ETHERNET"
            else -> "NONE"
        }

        return DeviceHealth(
            backendConnected = checkBackendConnectivity(),
            authValid = checkAuthValidity(),
            usageAccess = PermissionManager(context).isUsageAccessGranted(),
            vpnActive = VpnFilterEngine(context, scope).isVpnActive(),
            locationPerm = PermissionManager(context).isLocationPermissionGranted(),
            backgroundLoc = PermissionManager(context).isBackgroundLocationPermissionGranted(),
            notificationPerm = PermissionManager(context).isNotificationPermissionGranted(),
            backgroundService = isServiceRunning(),
            batteryOptimized = !isBatteryOptimized,
            appVersion = "1.0.0",
            policyVersion = 0, // Would be set from policy manager
            batteryLevel = batteryLevel,
            networkType = networkType,
        )
    }

    private fun checkBackendConnectivity(): Boolean {
        // Simple connectivity check - in production would ping backend health endpoint
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = connectivityManager.activeNetwork
        return network != null
    }

    private fun checkAuthValidity(): Boolean {
        // Check if device credentials are valid
        return true // Placeholder
    }

    private fun isServiceRunning(): Boolean {
        // Check if Guardian service is running
        return true // Placeholder
    }

    fun getCurrentHealth(): DeviceHealth = currentHealth

    fun getLastHealthCheckTime(): Long = lastHealthCheck

    fun stopMonitoring() {
        isMonitoring = false
    }

    fun getProtectionStatus(): String {
        val health = currentHealth
        if (!health.backendConnected) return "OFFLINE"
        if (!health.authValid) return "SUSPENDED"
        if (!health.usageAccess || !health.vpnActive || !health.locationPerm) return "PARTIALLY_PROTECTED"
        return "PROTECTED"
    }

    fun updateHealth() {
        currentHealth = performHealthCheck()
    }
}