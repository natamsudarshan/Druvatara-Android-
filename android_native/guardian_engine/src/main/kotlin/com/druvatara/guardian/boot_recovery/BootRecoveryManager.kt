package com.druvatara.guardian.boot_recovery

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import com.druvatara.guardian.engine.GuardianEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class BootRecoveryManager(
    private val context: Context,
    private val scope: CoroutineScope,
) {
    private val TAG = "BootRecoveryManager"
    private var bootReceiver: BroadcastReceiver? = null

    suspend fun registerBootReceiver() = withContext(Dispatchers.IO) {
        bootReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
                    intent.action == Intent.ACTION_LOCKED_BOOT_COMPLETED ||
                    intent.action == "android.intent.action.QUICKBOOT_POWERON") {
                    onBootCompleted(context)
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_BOOT_COMPLETED)
            addAction(Intent.ACTION_LOCKED_BOOT_COMPLETED)
            addAction("android.intent.action.QUICKBOOT_POWERON")
        }

        context.registerReceiver(bootReceiver, filter, Context.RECEIVER_EXPORTED)
        Log.d(TAG, "Boot receiver registered")
    }

    private fun onBootCompleted(context: Context) {
        Log.d(TAG, "Boot completed, starting Guardian services")
        scope.launch(Dispatchers.IO) {
            try {
                // Small delay to let system settle
                kotlinx.coroutines.delay(5000)

                // Restart Guardian engine
                GuardianEngine.getInstance()?.let { engine ->
                    // Re-initialize components
                    engine.policyManager.loadLocalPolicy()
                    engine.appInventoryEngine.startMonitoring()
                    engine.usageEngine.startCollection()
                    engine.screenTimeEngine.startEnforcement()
                    engine.scheduleEngine.startSchedules()
                    engine.locationEngine.startLocationUpdates()
                    engine.geofenceEngine.registerGeofences()
                    engine.deviceHealthEngine.startHealthMonitoring()
                    engine.eventQueue.startProcessing(object : com.druvatara.guardian.event_queue.EventQueue.EventProcessor {
                        override fun processEvent(event: com.druvatara.guardian.event_queue.EventQueue.DeviceEvent) {
                            engine.syncEngine.forceSync(scope)
                        }
                    })
                    engine.syncEngine.startSync()

                    Log.d(TAG, "Guardian services restored after boot")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error during boot recovery", e)
            }
        }
    }

    fun unregisterBootReceiver() {
        bootReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (e: Exception) {
                Log.w(TAG, "Error unregistering boot receiver", e)
            }
        }
    }
}