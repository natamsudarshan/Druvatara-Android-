package com.druvatara.guardian.permission

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class PermissionManager(private val context: Context) {
    private val TAG = "PermissionManager"
    private val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager

    companion object {
        const val USAGE_ACCESS_OP = "android:get_usage_stats"
        const val NOTIFICATION_LISTENER_OP = "android:notification_listener"
    }

    fun isUsageAccessGranted(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP_MR1) return true
        val mode = appOpsManager.checkOpNoThrow(USAGE_ACCESS_OP, Process.myUid(), context.packageName)
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun isNotificationPermissionGranted(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return context.checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        }
        return true
    }

    fun isLocationPermissionGranted(): Boolean {
        return context.checkSelfPermission(android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
    }

    fun isBackgroundLocationPermissionGranted(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return context.checkSelfPermission(android.Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED
        }
        return true
    }

    fun isOverlayPermissionGranted(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return Settings.canDrawOverlays(context)
        }
        return true
    }

    fun isVpnPermissionGranted(): Boolean {
        // VPN permission is granted per-session, check if our VPN service is prepared
        return true // Would check actual VPN state
    }

    fun getAllPermissionStatus(): Map<String, PermissionStatus> {
        return mapOf(
            "USAGE_ACCESS" to PermissionStatus("USAGE_ACCESS", isUsageAccessGranted(), isUsageAccessMandatory()),
            "NOTIFICATIONS" to PermissionStatus("NOTIFICATIONS", isNotificationPermissionGranted(), true),
            "LOCATION" to PermissionStatus("LOCATION", isLocationPermissionGranted(), true),
            "BACKGROUND_LOCATION" to PermissionStatus("BACKGROUND_LOCATION", isBackgroundLocationPermissionGranted(), false),
            "OVERLAY" to PermissionStatus("OVERLAY", isOverlayPermissionGranted(), false),
        )
    }

    private fun isUsageAccessMandatory(): Boolean {
        return true // Core feature
    }

    fun openUsageAccessSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        }
    }

    fun openNotificationSettings() {
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
            putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun openLocationSettings() {
        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    fun openOverlaySettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
                data = Uri.parse("package:${context.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        }
    }

    fun openBatteryOptimizationSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:${context.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        }
    }

    fun onPermissionGranted(permission: String) {
        Log.d(TAG, "Permission granted: $permission")
        // Notify engine
    }

    fun onPermissionRevoked(permission: String) {
        Log.w(TAG, "Permission revoked: $permission")
        // Notify engine
    }

    fun checkAllPermissions() {
        // Check all required permissions and log status
        Log.d(TAG, "Permission status: ${getAllPermissionStatus()}")
    }

    data class PermissionStatus(
        val permission: String,
        val isGranted: Boolean,
        val isMandatory: Boolean,
    ) {
        val status: String
            get() = if (isGranted) "GRANTED" else if (isMandatory) "REQUIRED" else "OPTIONAL"
    }
}