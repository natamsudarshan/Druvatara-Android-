package com.druvatara.guardian.usage

import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.concurrent.ConcurrentHashMap

class UsageEngine(
    private val context: Context,
    private val scope: CoroutineScope,
) {
    private val TAG = "UsageEngine"
    private val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    private val appUsageCache = ConcurrentHashMap<String, AppUsageData>()
    private var isCollecting = false

    data class AppUsageData(
        val packageName: String,
        var totalTimeMs: Long = 0,
        var launchCount: Int = 0,
        var lastUsedTime: Long = 0,
        var firstUsedTime: Long = 0,
    )

    suspend fun startCollection() = withContext(Dispatchers.IO) {
        if (isCollecting) return@withContext
        isCollecting = true
        collectUsageStats()
    }

    private fun collectUsageStats() {
        scope.launch(Dispatchers.IO) {
            while (isCollecting) {
                try {
                    val endTime = System.currentTimeMillis()
                    val startTime = getStartOfDay(endTime)

                    val usageStats = usageStatsManager.queryUsageStats(
                        UsageStatsManager.INTERVAL_DAILY,
                        startTime,
                        endTime
                    )

                    usageStats?.forEach { stat ->
                        val packageName = stat.packageName
                        val data = appUsageCache.getOrPut(packageName) { AppUsageData(packageName) }
                        data.totalTimeMs = stat.totalTimeInForeground
                        data.lastUsedTime = stat.lastTimeUsed
                        data.firstUsedTime = stat.firstTimeStamp
                        data.launchCount++
                    }

                    Log.d(TAG, "Collected usage stats for ${appUsageCache.size} apps")
                } catch (e: Exception) {
                    Log.e(TAG, "Error collecting usage stats", e)
                }

                try {
                    kotlinx.coroutines.delay(5 * 60 * 1000) // 5 minutes
                } catch (e: InterruptedException) {
                    break
                }
            }
        }
    }

    fun getAppUsageToday(packageName: String): Long {
        return appUsageCache[packageName]?.totalTimeMs ?: 0
    }

    fun getTotalUsageToday(): Long {
        return appUsageCache.values.sumOf { it.totalTimeMs }
    }

    fun getAppUsageData(packageName: String): AppUsageData? {
        return appUsageCache[packageName]
    }

    fun getAllUsageData(): List<AppUsageData> {
        return appUsageCache.values.toList()
    }

    fun stopCollection() {
        isCollecting = false
    }

    private fun getStartOfDay(timestamp: Long): Long {
        val calendar = java.util.Calendar.getInstance()
        calendar.timeInMillis = timestamp
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0)
        calendar.set(java.util.Calendar.MINUTE, 0)
        calendar.set(java.util.Calendar.SECOND, 0)
        calendar.set(java.util.Calendar.MILLISECOND, 0)
        return calendar.timeInMillis
    }

    fun isUsageAccessGranted(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP_MR1) return true
        val packages = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            System.currentTimeMillis() - 24 * 60 * 60 * 1000,
            System.currentTimeMillis()
        )
        return packages != null && packages.isNotEmpty()
    }
}