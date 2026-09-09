package com.druvatara.guardian.engine

import android.content.Context
import android.util.Log
import com.druvatara.guardian.policy.PolicyManager
import com.druvatara.guardian.policy.PolicyEngine
import com.druvatara.guardian.usage.UsageEngine
import com.druvatara.guardian.app_inventory.AppInventoryEngine
import com.druvatara.guardian.app_control.AppControlEngine
import com.druvatara.guardian.screen_time.ScreenTimeEngine
import com.druvatara.guardian.schedule.ScheduleEngine
import com.druvatara.guardian.vpn.VpnFilterEngine
import com.druvatara.guardian.location.LocationEngine
import com.druvatara.guardian.geofence.GeofenceEngine
import com.druvatara.guardian.device_health.DeviceHealthEngine
import com.druvatara.guardian.event_queue.EventQueue
import com.druvatara.guardian.sync.SyncEngine
import com.druvatara.guardian.boot_recovery.BootRecoveryManager
import com.druvatara.guardian.tamper_detection.TamperDetectionManager
import com.druvatara.guardian.permission.PermissionManager
import com.druvatara.guardian.capability.CapabilityManager
import com.druvatara.guardian.identity.DeviceIdentityManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.cancel

class GuardianEngine private constructor(
    private val context: Context,
    private val scope: CoroutineScope,
) {
    companion object {
        @Volatile private var INSTANCE: GuardianEngine? = null
        private val TAG = "GuardianEngine"

        fun initialize(context: Context, scope: CoroutineScope): GuardianEngine {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: GuardianEngine(context.applicationContext, scope).also { INSTANCE = it }
            }
        }

        fun getInstance(): GuardianEngine? = INSTANCE
    }

    // Core managers (no scope needed)
    val permissionManager: PermissionManager = PermissionManager(context)
    val policyManager: PolicyManager = PolicyManager(context)
    val deviceIdentityManager: DeviceIdentityManager = DeviceIdentityManager(context)
    val appControlEngine: AppControlEngine = AppControlEngine(context)

    // Engines with scope
    val usageEngine: UsageEngine = UsageEngine(context, scope)
    val appInventoryEngine: AppInventoryEngine = AppInventoryEngine(context, scope)
    val screenTimeEngine: ScreenTimeEngine = ScreenTimeEngine(context, usageEngine)
    val scheduleEngine: ScheduleEngine = ScheduleEngine(context)
    val vpnFilterEngine: VpnFilterEngine = VpnFilterEngine(context, scope)
    val locationEngine: LocationEngine = LocationEngine(context, scope)
    val geofenceEngine: GeofenceEngine = GeofenceEngine(context)
    val deviceHealthEngine: DeviceHealthEngine = DeviceHealthEngine(context, scope)
    val eventQueue: EventQueue = EventQueue(context, scope)
    val syncEngine: SyncEngine = SyncEngine(context, scope)
    val bootRecoveryManager: BootRecoveryManager = BootRecoveryManager(context, scope)
    val tamperDetectionManager: TamperDetectionManager = TamperDetectionManager(context)
    val capabilityManager: CapabilityManager = CapabilityManager(context, scope)
    
    // Policy engine depends on other engines
    val policyEnforcementEngine: PolicyEngine = PolicyEngine(
        context, policyManager, appControlEngine, screenTimeEngine, scheduleEngine, vpnFilterEngine
    )

    init {
        Log.d("GuardianEngine", "GuardianEngine initialized")
        startEngines()
    }

    private fun startEngines() {
        scope.launch(Dispatchers.IO) {
            deviceIdentityManager.initialize()
            permissionManager.checkAllPermissions()
            capabilityManager.detectCapabilities()
            policyManager.loadLocalPolicy()
            appInventoryEngine.startMonitoring()
            usageEngine.startCollection()
            screenTimeEngine.startEnforcement()
            scheduleEngine.startSchedules()
            locationEngine.startLocationUpdates()
            geofenceEngine.registerGeofences()
            deviceHealthEngine.startHealthMonitoring()
            eventQueue.startProcessing(object : com.druvatara.guardian.event_queue.EventQueue.EventProcessor {
                override fun processEvent(event: com.druvatara.guardian.event_queue.EventQueue.DeviceEvent) {
                    syncEngine.forceSync(scope)
                }
            })
            syncEngine.startSync()
            bootRecoveryManager.registerBootReceiver()
            tamperDetectionManager.startMonitoring()
        }
    }

    fun shutdown() {
        scope.cancel()
        Log.d("GuardianEngine", "GuardianEngine shutdown")
    }

    fun onPolicyUpdated(policyJson: String) {
        scope.launch {
            policyManager.updatePolicy(policyJson)
            policyEnforcementEngine.applyPolicy()
            screenTimeEngine.updateLimits()
            scheduleEngine.updateSchedules()
            vpnFilterEngine.updateFilterRules()
            geofenceEngine.updateGeofences(policyManager.getSafeZones())
        }
    }

    fun onPermissionGranted(permission: String) {
        scope.launch {
            permissionManager.onPermissionGranted(permission)
            capabilityManager.refreshCapability(permission)
        }
    }

    fun onPermissionRevoked(permission: String) {
        scope.launch {
            permissionManager.onPermissionRevoked(permission)
            capabilityManager.refreshCapability(permission)
            deviceHealthEngine.updateHealth()
        }
    }

    fun getProtectionStatus(): ProtectionStatus {
        return ProtectionStatus(
            isProtected = policyManager.isPolicyActive(),
            vpnActive = vpnFilterEngine.isVpnActive(),
            usageAccessGranted = permissionManager.isUsageAccessGranted(),
            locationPermissionGranted = permissionManager.isLocationPermissionGranted(),
            notificationPermissionGranted = permissionManager.isNotificationPermissionGranted(),
            lastSyncTime = syncEngine.getLastSyncTime(),
            policyVersion = policyManager.getCurrentPolicyVersion(),
        )
    }

    data class ProtectionStatus(
        val isProtected: Boolean,
        val vpnActive: Boolean,
        val usageAccessGranted: Boolean,
        val locationPermissionGranted: Boolean,
        val notificationPermissionGranted: Boolean,
        val lastSyncTime: Long,
        val policyVersion: Int,
    )
}