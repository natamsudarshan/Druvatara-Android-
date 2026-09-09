package com.druvatara.guardian.tamper_detection

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class TamperDetectionManager(private val context: Context) {
    private val TAG = "TamperDetectionManager"
    private var isMonitoring = false

    data class TamperStatus(
        val isRooted: Boolean = false,
        val isDebuggable: Boolean = false,
        val isEmulator: Boolean = false,
        val hasHookingFrameworks: Boolean = false,
        val appSignatureValid: Boolean = true,
        val installerValid: Boolean = true,
        val lastCheck: Long = System.currentTimeMillis(),
    )

    suspend fun startMonitoring() = withContext(Dispatchers.IO) {
        isMonitoring = true
        while (isMonitoring) {
            try {
                val status = performTamperCheck()
                if (status.isRooted || status.hasHookingFrameworks || !status.appSignatureValid) {
                    Log.w(TAG, "Tamper detected: $status")
                    reportTampering(status)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Tamper check failed", e)
            }
            try {
                Thread.sleep(30 * 60 * 1000) // 30 minutes
            } catch (e: InterruptedException) {
                break
            }
        }
    }

    private fun performTamperCheck(): TamperStatus {
        return TamperStatus(
            isRooted = checkRoot(),
            isDebuggable = checkDebuggable(),
            isEmulator = checkEmulator(),
            hasHookingFrameworks = checkHookingFrameworks(),
            appSignatureValid = checkAppSignature(),
            installerValid = checkInstaller(),
            lastCheck = System.currentTimeMillis(),
        )
    }

    private fun checkRoot(): Boolean {
        val rootPaths = listOf(
            "/system/bin/su", "/system/xbin/su", "/sbin/su",
            "/system/sbin/su", "/vendor/bin/su", "/su/bin/su",
            "/magisk/.core/bin/su",
        )

        return rootPaths.any { java.io.File(it).exists() } ||
            java.lang.Runtime.getRuntime().exec("which su").inputStream.read() != -1
    }

    private fun checkDebuggable(): Boolean {
        return (context.applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }

    private fun checkEmulator(): Boolean {
        return Build.FINGERPRINT.startsWith("generic")
            || Build.FINGERPRINT.startsWith("unknown")
            || Build.MODEL.contains("google_sdk")
            || Build.MODEL.contains("Emulator")
            || Build.MODEL.contains("Android SDK built for x86")
            || Build.MANUFACTURER.contains("Genymotion")
            || (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
            || "google_sdk".equals(Build.PRODUCT)
    }

    private fun checkHookingFrameworks(): Boolean {
        val hookingLibs = listOf(
            "libxposed_art.so", "libxposed.so", "libepic.so",
            "libfrida-agent.so", "libfrida-gadget.so", "libfrida-gadget-64.so",
            "libsubstrate.so", "libdobby.so", "libdobby-64.so",
        )

        val mapsFile = java.io.File("/proc/self/maps")
        if (mapsFile.exists()) {
            val content = mapsFile.readText()
            return hookingLibs.any { content.contains(it) }
        }
        return false
    }

    private fun checkAppSignature(): Boolean {
        try {
            val packageInfo = context.packageManager.getPackageInfo(
                context.packageName, PackageManager.GET_SIGNATURES
            )
            val signatures = packageInfo.signatures
            // In production, compare with known valid signatures
            return signatures?.isNotEmpty() == true
        } catch (e: Exception) {
            return false
        }
    }

    private fun checkInstaller(): Boolean {
        val installer = context.packageManager.getInstallerPackageName(context.packageName)
        // Allow Play Store, or specific trusted installers
        return installer == "com.android.vending" || installer == null
    }

    private fun reportTampering(status: TamperStatus) {
        // Send tamper event to backend
        // For now, just log
        Log.w(TAG, "Tamper event: ${status.toString()}")
    }

    fun stopMonitoring() {
        isMonitoring = false
    }

    fun getTamperStatus(): TamperStatus {
        return performTamperCheck()
    }
}