package com.druvatara.guardian.policy

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.druvatara.guardian.app_control.AppControlEngine
import com.druvatara.guardian.screen_time.ScreenTimeEngine
import com.druvatara.guardian.schedule.ScheduleEngine
import com.druvatara.guardian.vpn.VpnFilterEngine
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class PolicyEngine(
    private val context: Context,
    private val policyManager: PolicyManager,
    private val appControlEngine: AppControlEngine,
    private val screenTimeEngine: ScreenTimeEngine,
    private val scheduleEngine: ScheduleEngine,
    private val vpnFilterEngine: VpnFilterEngine,
) {
    private val TAG = "PolicyEngine"

    suspend fun applyPolicy() = withContext(Dispatchers.IO) {
        Log.d(TAG, "Applying policy version ${policyManager.getCurrentPolicyVersion()}")

        val policy = policyManager.getCurrentPolicy() ?: return@withContext

        screenTimeEngine.applyScreenTimeRules(policyManager.getScreenTimeRules())
        scheduleEngine.applySchedules(policyManager.getSchedules())
        appControlEngine.applyAppRules(policyManager.getAppRules(), policyManager.getEssentialApps())
        vpnFilterEngine.applyFilterRules(policyManager.getWebSafetyRules())

        Log.d(TAG, "Policy applied successfully")
    }

    fun evaluateAppLaunch(packageName: String): AppLaunchDecision {
        val policy = policyManager.getCurrentPolicy() ?: return AppLaunchDecision.ALLOW

        // Check essential apps first (highest precedence)
        if (packageName in policyManager.getEssentialApps()) {
            return AppLaunchDecision.ALLOW
        }

        // Check active schedules
        val activeSchedule = scheduleEngine.getActiveSchedule()
        if (activeSchedule != null) {
            if (packageName !in activeSchedule.allowedApps) {
                return AppLaunchDecision.BLOCK_SCHEDULE
            }
        }

        // Check app-specific rules
        val appRules = policyManager.getAppRules()
        val appRule = appRules.firstOrNull { it.packageName == packageName }
        when (appRule?.ruleType) {
            "BLOCK" -> return AppLaunchDecision.BLOCK_APP_RULE
            "LIMIT" -> {
                val limitMs = (appRule.config["limitMs"] as? Long) ?: 0
                val usedMs = screenTimeEngine.getAppUsageToday(packageName)
                if (usedMs >= limitMs) return AppLaunchDecision.BLOCK_APP_LIMIT
            }
            "ESSENTIAL" -> return AppLaunchDecision.ALLOW
        }

        // Check total screen time limit
        val screenTimeRules = policyManager.getScreenTimeRules()
        val totalUsedToday = screenTimeEngine.getTotalUsageToday()
        if (totalUsedToday >= screenTimeRules.dailyLimitMs) {
            return AppLaunchDecision.BLOCK_DAILY_LIMIT
        }

        // Check temporary overrides
        val overrides = policyManager.getTemporaryOverrides()
        val now = System.currentTimeMillis()
        val relevantOverride = overrides.firstOrNull { it.resource == "APP:$packageName" && it.startTime <= now && it.expiryTime > now }
        if (relevantOverride != null) {
            return AppLaunchDecision.ALLOW_TEMPORARY
        }

        return AppLaunchDecision.ALLOW
    }

    fun evaluateWebsiteAccess(url: String): WebsiteDecision {
        val webSafety = policyManager.getWebSafetyRules()

        if (webSafety.mode == "OFF") return WebsiteDecision.ALLOW

        val domain = extractDomain(url)
        if (domain == null) return WebsiteDecision.ALLOW

        // Check allowlist first
        if (domain in webSafety.allowlist) return WebsiteDecision.ALLOW

        // Check blocklist
        if (domain in webSafety.blocklist) return WebsiteDecision.BLOCK_PARENT

        // Check essential infrastructure
        if (isEssentialDomain(domain)) return WebsiteDecision.ALLOW

        // Check threat intelligence (would be implemented with threat engine)
        // For now, return ALLOW and let VPN filter handle it

        return WebsiteDecision.ALLOW
    }

    private fun extractDomain(url: String): String? {
        return try {
            val uri = android.net.Uri.parse(url)
            uri.host?.let { host ->
                if (host.startsWith("www.")) host.substring(4) else host
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun isEssentialDomain(domain: String): Boolean {
        val essentialDomains = setOf(
            "google.com", "googleapis.com", "gstatic.com",
            "android.com", "play.googleapis.com",
            "druvatara.com", "api.druvatara.com",
            "firebaseinstallations.googleapis.com",
            "fcm.googleapis.com",
        )
        return essentialDomains.any { domain.endsWith(it) }
    }

    fun getCurrentProtectionState(): ProtectionState {
        val policy = policyManager.getCurrentPolicy() ?: return ProtectionState.UNCONFIGURED

        var issues = mutableListOf<String>()

        if (!policyManager.isPolicyActive()) issues.add("NO_POLICY")
        if (!vpnFilterEngine.isVpnActive()) issues.add("VPN_INACTIVE")
        if (screenTimeEngine.isLimitExceeded()) issues.add("SCREEN_TIME_EXCEEDED")
        if (scheduleEngine.isInRestrictedSchedule()) issues.add("IN_RESTRICTED_SCHEDULE")

        return if (issues.isEmpty()) {
            ProtectionState.PROTECTED
        } else {
            ProtectionState.PARTIALLY_PROTECTED
        }
    }

    enum class AppLaunchDecision {
        ALLOW,
        BLOCK_APP_RULE,
        BLOCK_APP_LIMIT,
        BLOCK_DAILY_LIMIT,
        BLOCK_SCHEDULE,
        ALLOW_TEMPORARY,
    }

    enum class WebsiteDecision {
        ALLOW,
        BLOCK_CATEGORY,
        BLOCK_THREAT,
        BLOCK_PARENT,
        ALLOW_PARENT_OVERRIDE,
        UNKNOWN,
        ERROR,
    }

    enum class ProtectionState {
        PROTECTED,
        PARTIALLY_PROTECTED,
        ATTENTION_REQUIRED,
        SETUP_INCOMPLETE,
        OFFLINE,
        UNCONFIGURED,
    }
}