package com.druvatara.guardian.screen_time

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.druvatara.guardian.policy.ScreenTimeRules
import com.druvatara.guardian.usage.UsageEngine
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.ConcurrentHashMap

class ScreenTimeEngine(
    private val context: Context,
    private val usageEngine: UsageEngine,
) {
    private val TAG = "ScreenTimeEngine"
    private var currentRules: ScreenTimeRules = ScreenTimeRules.getDefault()
    private var isEnforcing = false
    private val warningCallbacks = mutableListOf<(Long) -> Unit>()

    suspend fun startEnforcement() = withContext(Dispatchers.IO) {
        isEnforcing = true
        monitorScreenTime()
    }

    fun applyScreenTimeRules(rules: ScreenTimeRules) {
        currentRules = rules
    }

    fun getTotalUsageToday(): Long {
        return usageEngine.getTotalUsageToday()
    }

    fun getAppUsageToday(packageName: String): Long {
        return usageEngine.getAppUsageToday(packageName)
    }

    fun getRemainingTime(): Long {
        val used = getTotalUsageToday()
        return maxOf(0, currentRules.dailyLimitMs - used)
    }

    fun isLimitExceeded(): Boolean {
        return getRemainingTime() <= 0
    }

    fun getWarningThresholds(): List<Long> {
        return currentRules.warningThresholds
    }

    fun registerWarningCallback(callback: (Long) -> Unit) {
        warningCallbacks.add(callback)
    }

    private fun monitorScreenTime() {
        while (isEnforcing) {
            try {
                val remaining = getRemainingTime()
                val thresholds = currentRules.warningThresholds

                for (threshold in thresholds) {
                    if (remaining <= threshold && remaining > 0) {
                        warningCallbacks.forEach { it(remaining) }
                    }
                }

                if (isLimitExceeded()) {
                    enforceLimit()
                }

                Thread.sleep(60 * 1000) // Check every minute
            } catch (e: Exception) {
                Log.e(TAG, "Error monitoring screen time", e)
            }
        }
    }

    private fun enforceLimit() {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningTasks = activityManager.getRunningTasks(1)
        val topActivity = runningTasks?.firstOrNull()?.topActivity
        val topPackage = topActivity?.packageName

        if (topPackage != null && topPackage !in currentRules.essentialApps) {
            // Show screen time limit screen
            val intent = Intent(context, ScreenTimeLimitActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            context.startActivity(intent)
        }
    }

    fun stopEnforcement() {
        isEnforcing = false
    }

    fun updateLimits() {
        // Limits are applied via applyScreenTimeRules
    }
}