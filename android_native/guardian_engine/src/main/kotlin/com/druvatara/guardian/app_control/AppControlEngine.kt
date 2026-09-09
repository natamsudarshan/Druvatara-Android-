package com.druvatara.guardian.app_control

import android.app.ActivityManager
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import android.util.Log
import com.druvatara.guardian.policy.AppRule
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class AppControlEngine(private val context: Context) {
    private val TAG = "AppControlEngine"
    private val packageManager = context.packageManager
    private var currentAppRules = mutableMapOf<String, AppRule>()
    private var essentialApps = mutableSetOf<String>()

    fun applyAppRules(rules: List<AppRule>, essentialAppsList: List<String>) {
        currentAppRules.clear()
        rules.forEach { currentAppRules[it.packageName] = it }
        essentialApps = essentialAppsList.toMutableSet()
    }

    fun isAppBlocked(packageName: String): Boolean {
        if (packageName in essentialApps) return false
        if (isSystemApp(packageName)) return false

        val rule = currentAppRules[packageName]
        return when (rule?.ruleType) {
            "BLOCK" -> true
            "LIMIT" -> {
                val limitMs = (rule.config["limitMs"] as? Long) ?: 0
                // Would check actual usage - placeholder
                false
            }
            else -> false
        }
    }

    fun getBlockReason(packageName: String): String? {
        if (packageName in essentialApps) return null
        val rule = currentAppRules[packageName]
        return when (rule?.ruleType) {
            "BLOCK" -> "App blocked by parent"
            "LIMIT" -> "Time limit reached"
            else -> null
        }
    }

    fun launchBlockScreen(packageName: String) {
        val intent = Intent(context, AppBlockedActivity::class.java)
        intent.putExtra("package_name", packageName)
        intent.putExtra("reason", getBlockReason(packageName) ?: "Blocked by parental controls")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        context.startActivity(intent)
    }

    fun requestAppAccess(packageName: String): Boolean {
        // Send request to backend for parent approval
        return false // Placeholder
    }

    fun grantTemporaryAccess(packageName: String, durationMs: Long) {
        // Grant temporary access
        // Would use AppOpsManager or custom logic
    }

    private fun isSystemApp(packageName: String): Boolean {
        try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            return (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
        } catch (e: Exception) {
            return false
        }
    }

    // For devices with Device Owner or Profile Owner
    fun setPackagesSuspended(packageNames: List<String>, suspended: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
            if (dpm.isDeviceOwnerApp(context.packageName) || dpm.isProfileOwnerApp(context.packageName)) {
                val componentName = android.content.ComponentName(context, AdminReceiver::class.java)
                dpm.setPackagesSuspended(componentName, packageNames.toTypedArray(), suspended)
            }
        }
    }

    fun hideApp(packageName: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
            val componentName = android.content.ComponentName(context, AdminReceiver::class.java)
            if (dpm.isDeviceOwnerApp(context.packageName) || dpm.isProfileOwnerApp(context.packageName)) {
                dpm.setApplicationHidden(componentName, packageName, true)
            }
        }
    }

    fun showApp(packageName: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
            val componentName = android.content.ComponentName(context, AdminReceiver::class.java)
            if (dpm.isDeviceOwnerApp(context.packageName) || dpm.isProfileOwnerApp(context.packageName)) {
                dpm.setApplicationHidden(componentName, packageName, false)
            }
        }
    }

    // Admin receiver for device admin features
    class AdminReceiver : android.app.admin.DeviceAdminReceiver()
}