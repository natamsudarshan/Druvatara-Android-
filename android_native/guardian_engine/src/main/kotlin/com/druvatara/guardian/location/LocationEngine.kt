package com.druvatara.guardian.location

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import com.druvatara.guardian.policy.LocationSettings
import com.druvatara.guardian.policy.SafeZone
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.concurrent.ConcurrentHashMap

class LocationEngine(
    private val context: Context,
    private val scope: CoroutineScope,
) {
    private val TAG = "LocationEngine"
    private val fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
    private var locationCallback: LocationCallback? = null
    private var isTracking = false
    private var currentSettings: LocationSettings = LocationSettings.getDefault()
    private val locationListeners = mutableListOf<(Location) -> Unit>()

    suspend fun startLocationUpdates() = withContext(Dispatchers.IO) {
        if (isTracking) return@withContext
        if (!hasLocationPermission()) {
            Log.w(TAG, "Location permission not granted")
            return@withContext
        }

        isTracking = true
        createLocationCallback()
        requestLocationUpdates()
    }

    private fun createLocationCallback() {
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult.locations.forEach { location ->
                    notifyListeners(location)
                }
            }
        }
    }

    private fun requestLocationUpdates() {
        val request = LocationRequest.Builder(Priority.PRIORITY_BALANCED_POWER_ACCURACY, currentSettings.updateIntervalMs)
            .setMinUpdateIntervalMillis(currentSettings.updateIntervalMs / 2)
            .setMinUpdateDistanceMeters(10f)
            .build()

        fusedLocationClient.requestLocationUpdates(request, locationCallback!!, Looper.getMainLooper())
    }

    fun addLocationListener(listener: (Location) -> Unit) {
        locationListeners.add(listener)
    }

    fun removeLocationListener(listener: (Location) -> Unit) {
        locationListeners.remove(listener)
    }

    private fun notifyListeners(location: Location) {
        locationListeners.forEach { it(location) }
    }

    fun getLastKnownLocation(): Location? {
        // In production, cache the last known location
        return null
    }

    fun hasLocationPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
    }

    suspend fun applySettings(settings: LocationSettings) = withContext(Dispatchers.IO) {
        currentSettings = settings
        if (isTracking) {
            fusedLocationClient.removeLocationUpdates(locationCallback!!)
            requestLocationUpdates()
        }
    }

    fun stopLocationUpdates() {
        isTracking = false
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
    }

    // Request permission from user
    fun requestLocationPermission(activity: Activity) {
        ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), 1002)
    }

    fun requestBackgroundLocationPermission(activity: Activity) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION), 1003)
        }
    }
}