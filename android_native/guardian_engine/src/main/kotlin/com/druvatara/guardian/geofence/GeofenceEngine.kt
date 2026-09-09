package com.druvatara.guardian.geofence

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.ActivityCompat
import com.druvatara.guardian.policy.SafeZone
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.ConcurrentHashMap

class GeofenceEngine(private val context: Context) {
    private val TAG = "GeofenceEngine"
    private val geofencingClient = LocationServices.getGeofencingClient(context)
    private val activeGeofences = ConcurrentHashMap<String, SafeZone>()
    private val geofencePendingIntent: PendingIntent? = createPendingIntent()

    companion object {
        private const val GEOFENCE_TRANSITION_ACTION = "com.druvatara.guardian.GEOFENCE_TRANSITION"
        private const val GEOFENCE_EXPIRATION_HOURS = 24
    }

    private fun createPendingIntent(): PendingIntent? {
        val intent = Intent(context, GeofenceBroadcastReceiver::class.java)
        intent.action = GEOFENCE_TRANSITION_ACTION
        return PendingIntent.getBroadcast(
            context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    suspend fun registerGeofences() = withContext(Dispatchers.IO) {
        // Geofences would be loaded from policy
        // This is called when policy is updated
    }

    suspend fun updateGeofences(geofences: List<SafeZone>) = withContext(Dispatchers.IO) {
        // Remove old geofences
        val oldGeofenceIds = activeGeofences.keys.toList()
        if (oldGeofenceIds.isNotEmpty()) {
            geofencingClient.removeGeofences(oldGeofenceIds)
        }

        activeGeofences.clear()

        // Add new geofences
        geofences.filter { it.isActive }.forEach { zone ->
            addGeofence(zone)
        }
    }

    private fun addGeofence(zone: SafeZone) {
        if (geofencePendingIntent == null) return

        val geofence = Geofence.Builder()
            .setRequestId(zone.id)
            .setCircularRegion(zone.latitude, zone.longitude, zone.radiusMeters.toFloat())
            .setExpirationDuration(GEOFENCE_EXPIRATION_HOURS * 60 * 60 * 1000L)
            .setTransitionTypes(
                (if (zone.alertOnEnter) Geofence.GEOFENCE_TRANSITION_ENTER else 0) or
                (if (zone.alertOnExit) Geofence.GEOFENCE_TRANSITION_EXIT else 0)
            )
            .setLoiteringDelay(30_000) // 30 seconds
            .build()

        val request = GeofencingRequest.Builder()
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            .addGeofence(geofence)
            .build()

        geofencingClient.addGeofences(request, geofencePendingIntent!!)
            .addOnSuccessListener {
                activeGeofences[zone.id] = zone
                Log.d(TAG, "Geofence added: ${zone.name}")
            }
            .addOnFailureListener { e ->
                Log.e(TAG, "Failed to add geofence: ${zone.name}", e)
            }
    }

    fun removeGeofence(geofenceId: String) {
        activeGeofences.remove(geofenceId)
        geofencingClient.removeGeofences(listOf(geofenceId))
    }

    fun getActiveGeofences(): List<SafeZone> {
        return activeGeofences.values.toList()
    }

    // Broadcast receiver would be registered in AndroidManifest.xml
    class GeofenceBroadcastReceiver : android.content.BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            // Handle geofence transitions
            // This would create events to send to backend
        }
    }
}