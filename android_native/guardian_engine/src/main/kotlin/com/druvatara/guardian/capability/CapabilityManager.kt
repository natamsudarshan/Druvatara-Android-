package com.druvatara.guardian.capability

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class CapabilityManager(
    private val context: Context,
    private val scope: CoroutineScope,
) {
    private val TAG = "CapabilityManager"
    private var capabilities = Capabilities()

    data class Capabilities(
        val usageStats: Boolean = false,
        val vpnFiltering: Boolean = false,
        val backgroundLocation: Boolean = false,
        val deviceOwner: Boolean = false,
        val accessibility: Boolean = false,
        val geofencing: Boolean = false,
        val notificationListener: Boolean = false,
        val packageVisibility: Boolean = false,
        val batteryOptimizationExempt: Boolean = false,
        val managedDeviceMode: Boolean = false,
        val playIntegrityAvailable: Boolean = false,
    )

    suspend fun detectCapabilities() = withContext(Dispatchers.IO) {
        capabilities = Capabilities(
            usageStats = checkUsageStats(),
            vpnFiltering = checkVpnFiltering(),
            backgroundLocation = checkBackgroundLocation(),
            deviceOwner = checkDeviceOwner(),
            accessibility = checkAccessibilityEligibility(),
            geofencing = checkGeofencing(),
            notificationListener = checkNotificationListener(),
            packageVisibility = checkPackageVisibility(),
            batteryOptimizationExempt = checkBatteryOptimizationExempt(),
            managedDeviceMode = checkManagedDeviceMode(),
            playIntegrityAvailable = checkPlayIntegrity(),
        )
        Log.d(TAG, "Detected capabilities: $capabilities")
    }

    private fun checkUsageStats(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP_MR1) return true
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as android.app.AppOpsManager
        return appOps.checkOpNoThrow("android:get_usage_stats", android.os.Process.myUid(), context.packageName) ==
            android.app.AppOpsManager.MODE_ALLOWED
    }

    private fun checkVpnFiltering(): Boolean {
        // VPN permission is granted at runtime
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP
    }

    private fun checkBackgroundLocation(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return true
        return context.checkSelfPermission(android.Manifest.permission.ACCESS_BACKGROUND_LOCATION) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun checkDeviceOwner(): Boolean {
        val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
        return dpm.isDeviceOwnerApp(context.packageName) ||
            dpm.isProfileOwnerApp(context.packageName)
    }

    private fun checkAccessibilityEligibility(): Boolean {
        // Check if we could use accessibility service
        // This is more about policy eligibility than technical capability
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN
    }

    private fun checkGeofencing(): Boolean {
        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as android.location.LocationManager
        return locationManager.isProviderEnabled(android.location.LocationManager.GPS_PROVIDER)
    }

    private fun checkNotificationListener(): Boolean {
        val enabledListeners = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")
        return enabledListeners?.contains(context.packageName) == true
    }

    private fun checkPackageVisibility(): Boolean {
        // Check if we have QUERY_ALL_PACKAGES or proper manifest queries
        try {
            context.packageManager.getPackageInfo("com.android.chrome", 0)
            return true
        } catch (e: PackageManager.NameNotFoundException) {
            return false
        }
    }

    private fun checkBatteryOptimizationExempt(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val pm = context.getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
            return pm.isIgnoringBatteryOptimizations(context.packageName)
        }
        return true
    }

    private fun checkManagedDeviceMode(): Boolean {
        val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
        return dpm.isDeviceOwnerApp(context.packageName)
    }

    private fun checkPlayIntegrity(): Boolean {
        // Check if Play Integrity API is available
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.N
    }

    fun getCapabilities(): Capabilities = capabilities

    fun refreshCapability(permission: String) {
        scope.launch(Dispatchers.IO) {
            when (permission) {
                "USAGE_ACCESS" -> capabilities = capabilities.copy(usageStats = checkUsageStats())
                "BACKGROUND_LOCATION" -> capabilities = capabilities.copy(backgroundLocation = checkBackgroundLocation())
                "VPN" -> capabilities = capabilities.copy(vpnFiltering = checkVpnFiltering())
                "NOTIFICATIONS" -> capabilities = capabilities.copy(notificationListener = checkNotificationListener())
                "BATTERY_OPTIMIZATION" -> capabilities = capabilities.copy(batteryOptimizationExempt = checkBatteryOptimizationExempt())
                "PACKAGE_VISIBILITY" -> capabilities = capabilities.copy(packageVisibility = checkPackageVisibility())
            }
        }
    }

    fun getCapabilityReport(): String {
        return capabilities.toString()
    }
}