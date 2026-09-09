package com.druvatara.guardian.policy

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class PolicyManager(private val context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("guardian_policy", Context.MODE_PRIVATE)
    private val gson = Gson()
    private var currentPolicy: DevicePolicy? = null

    companion object {
        private const val KEY_POLICY_JSON = "policy_json"
        private const val KEY_POLICY_VERSION = "policy_version"
        private const val KEY_PREVIOUS_POLICY_JSON = "previous_policy_json"
    }

    suspend fun loadLocalPolicy() = withContext(Dispatchers.IO) {
        val policyJson = prefs.getString(KEY_POLICY_JSON, null)
        val version = prefs.getInt(KEY_POLICY_VERSION, 0)
        if (policyJson != null) {
            try {
                currentPolicy = gson.fromJson(policyJson, DevicePolicy::class.java)
                currentPolicy?.version = version
            } catch (e: Exception) {
                // Fallback to previous policy
                loadPreviousPolicy()
            }
        }
    }

    private suspend fun loadPreviousPolicy() = withContext(Dispatchers.IO) {
        val previousJson = prefs.getString(KEY_PREVIOUS_POLICY_JSON, null)
        if (previousJson != null) {
            try {
                currentPolicy = gson.fromJson(previousJson, DevicePolicy::class.java)
            } catch (e: Exception) {
                currentPolicy = DevicePolicy.getDefault()
            }
        } else {
            currentPolicy = DevicePolicy.getDefault()
        }
    }

    suspend fun updatePolicy(policyJson: String) = withContext(Dispatchers.IO) {
        try {
            val newPolicy = gson.fromJson(policyJson, DevicePolicy::class.java)
            if (currentPolicy != null) {
                prefs.edit()
                    .putString(KEY_PREVIOUS_POLICY_JSON, gson.toJson(currentPolicy))
                    .apply()
            }
            prefs.edit()
                .putString(KEY_POLICY_JSON, policyJson)
                .putInt(KEY_POLICY_VERSION, newPolicy.version)
                .apply()
            currentPolicy = newPolicy
        } catch (e: Exception) {
            throw PolicyUpdateException("Failed to parse policy: ${e.message}")
        }
    }

    fun isPolicyActive(): Boolean = currentPolicy != null

    fun getCurrentPolicy(): DevicePolicy? = currentPolicy

    fun getCurrentPolicyVersion(): Int = currentPolicy?.version ?: 0

    fun getScreenTimeRules(): ScreenTimeRules = currentPolicy?.screenTime ?: ScreenTimeRules.getDefault()

    fun getAppRules(): List<AppRule> = currentPolicy?.applications?.rules ?: emptyList()

    fun getSchedules(): List<Schedule> = currentPolicy?.schedules ?: emptyList()

    fun getWebSafetyRules(): WebSafetyRules = currentPolicy?.webSafety ?: WebSafetyRules.getDefault()

    fun getLocationSettings(): LocationSettings = currentPolicy?.location ?: LocationSettings.getDefault()

    fun getSafeZones(): List<SafeZone> = currentPolicy?.safeZones ?: emptyList()

    fun getEssentialApps(): List<String> = currentPolicy?.essentialApps ?: emptyList()

    fun getTemporaryOverrides(): List<TemporaryOverride> = currentPolicy?.temporaryOverrides ?: emptyList()

    class PolicyUpdateException(message: String) : Exception(message)
}

data class DevicePolicy(
    var version: Int = 1,
    val screenTime: ScreenTimeRules? = null,
    val applications: ApplicationsPolicy? = null,
    val schedules: List<Schedule>? = null,
    val webSafety: WebSafetyRules? = null,
    val location: LocationSettings? = null,
    val safeZones: List<SafeZone>? = null,
    val essentialApps: List<String>? = null,
    val temporaryOverrides: List<TemporaryOverride>? = null,
) {
    companion object {
        fun getDefault(): DevicePolicy = DevicePolicy(
            version = 1,
            screenTime = ScreenTimeRules.getDefault(),
            applications = ApplicationsPolicy(rules = emptyList()),
            schedules = emptyList(),
            webSafety = WebSafetyRules.getDefault(),
            location = LocationSettings.getDefault(),
            safeZones = emptyList(),
            essentialApps = emptyList(),
            temporaryOverrides = emptyList(),
        )
    }
}

data class ScreenTimeRules(
    val dailyLimitMs: Long = 7_200_000, // 2 hours
    val essentialApps: List<String> = emptyList(),
    val warningThresholds: List<Long> = listOf(900_000, 300_000, 60_000), // 15min, 5min, 1min
) {
    companion object {
        fun getDefault(): ScreenTimeRules = ScreenTimeRules()
    }
}

data class ApplicationsPolicy(
    val rules: List<AppRule> = emptyList(),
)

data class AppRule(
    val packageName: String,
    val ruleType: String, // "BLOCK", "LIMIT", "ALLOW", "ESSENTIAL"
    val config: Map<String, Any> = emptyMap(),
)

data class Schedule(
    val id: String,
    val name: String,
    val scheduleType: String, // "BEDTIME", "SCHOOL", "CUSTOM"
    val startTime: String, // HH:mm
    val endTime: String, // HH:mm
    val days: List<Int>, // 1-7 (Mon-Sun)
    val timeZone: String,
    val allowedApps: List<String> = emptyList(),
    val isActive: Boolean = true,
)

data class WebSafetyRules(
    val mode: String = "MODERATE", // "STRICT", "MODERATE", "BASIC", "OFF"
    val safeSearch: Boolean = true,
    val categories: List<String> = emptyList(),
    val allowlist: List<String> = emptyList(),
    val blocklist: List<String> = emptyList(),
) {
    companion object {
        fun getDefault(): WebSafetyRules = WebSafetyRules()
    }
}

data class LocationSettings(
    val enabled: Boolean = true,
    val backgroundLocation: Boolean = false,
    val updateIntervalMs: Long = 300_000, // 5 minutes
    val accuracy: String = "BALANCED",
) {
    companion object {
        fun getDefault(): LocationSettings = LocationSettings()
    }
}

data class SafeZone(
    val id: String,
    val name: String,
    val latitude: Double,
    val longitude: Double,
    val radiusMeters: Int,
    val alertOnEnter: Boolean = true,
    val alertOnExit: Boolean = true,
    val isActive: Boolean = true,
)

data class TemporaryOverride(
    val id: String,
    val parentId: String,
    val resource: String, // "SCREEN_TIME", "APP:<packageName>", "SCHEDULE:<scheduleId>"
    val startTime: Long,
    val expiryTime: Long,
)