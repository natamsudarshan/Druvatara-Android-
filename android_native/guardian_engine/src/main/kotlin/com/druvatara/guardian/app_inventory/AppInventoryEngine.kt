package com.druvatara.guardian.app_inventory

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class AppInventoryEngine(
    private val context: Context,
    private val scope: CoroutineScope,
) {
    private val TAG = "AppInventoryEngine"
    private val packageManager = context.packageManager
    private var isMonitoring = false
    private val installedApps = mutableMapOf<String, AppInfo>()

    data class AppInfo(
        val packageName: String,
        val appName: String,
        val versionName: String?,
        val versionCode: Int,
        val category: String?,
        val iconUrl: String?,
        val isSystemApp: Boolean,
        var installState: String = "INSTALLED",
        var firstDetected: Long = System.currentTimeMillis(),
        var lastSeen: Long = System.currentTimeMillis(),
        var policyStatus: String = "UNMANAGED",
    )

    suspend fun startMonitoring() = withContext(Dispatchers.IO) {
        if (isMonitoring) return@withContext
        isMonitoring = true
        scanInstalledApps()
        registerPackageReceiver()
    }

    private fun scanInstalledApps() {
        val packages = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        val currentTime = System.currentTimeMillis()

        packages.forEach { appInfo ->
            val packageName = appInfo.packageName
            val existing = installedApps[packageName]

            val name = packageManager.getApplicationLabel(appInfo).toString()
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0 ||
                           (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0

            var versionName: String? = null
            var versionCode = 0
            try {
                val pkgInfo = packageManager.getPackageInfo(packageName, 0)
                versionName = pkgInfo.versionName
                versionCode = pkgInfo.versionCode
            } catch (e: Exception) {
                // Ignore
            }

            val appInfo = AppInfo(
                packageName = packageName,
                appName = name,
                versionName = versionName,
                versionCode = versionCode,
                category = guessCategory(appInfo),
                iconUrl = null, // Would be set from icon
                isSystemApp = isSystem,
                installState = if (existing != null) "INSTALLED" else "NEWLY_DETECTED",
                firstDetected = existing?.firstDetected ?: currentTime,
                lastSeen = currentTime,
            )

            installedApps[packageName] = appInfo
        }

        Log.d(TAG, "Scanned ${installedApps.size} installed apps")
    }

    private fun guessCategory(appInfo: ApplicationInfo): String? {
        // In production, use a proper categorization service
        val packageName = appInfo.packageName
        return when {
            packageName.startsWith("com.google.android") -> "SYSTEM"
            packageName.startsWith("com.android") -> "SYSTEM"
            packageName.contains("game") -> "GAMES"
            packageName.contains("social") -> "SOCIAL"
            packageName.contains("browser") -> "BROWSER"
            else -> "OTHER"
        }
    }

    private fun registerPackageReceiver() {
        val receiver = object : android.content.BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent) {
                val action = intent?.action
                val packageName = intent?.data?.schemeSpecificPart
                if (packageName == null) return

                when (action) {
                    Intent.ACTION_PACKAGE_ADDED, Intent.ACTION_PACKAGE_REPLACED -> {
                        scope.launch(Dispatchers.IO) { addApp(packageName) }
                    }
                    Intent.ACTION_PACKAGE_REMOVED -> {
                        scope.launch(Dispatchers.IO) { removeApp(packageName) }
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REPLACED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addDataScheme("package")
        }

        context.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
    }

    private fun addApp(packageName: String) {
        try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            val name = packageManager.getApplicationLabel(appInfo).toString()
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

            installedApps[packageName] = AppInfo(
                packageName = packageName,
                appName = name,
                versionName = null,
                versionCode = 0,
                category = guessCategory(appInfo),
                iconUrl = null,
                isSystemApp = isSystem,
                installState = "INSTALLED",
            )
            Log.d(TAG, "App installed: $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "Error adding app", e)
        }
    }

    private fun removeApp(packageName: String) {
        installedApps[packageName]?.let { it.installState = "REMOVED" }
        Log.d(TAG, "App removed: $packageName")
    }

    fun getInstalledApps(): List<AppInfo> {
        return installedApps.values.filter { it.installState == "INSTALLED" }.toList()
    }

    fun getAppInfo(packageName: String): AppInfo? {
        return installedApps[packageName]
    }

    fun stopMonitoring() {
        isMonitoring = false
    }
}