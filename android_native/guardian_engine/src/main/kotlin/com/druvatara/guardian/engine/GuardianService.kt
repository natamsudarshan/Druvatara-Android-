package com.druvatara.guardian.engine

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat.startForegroundService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class GuardianService : Service() {
    private val TAG = "GuardianService"
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var guardianEngine: GuardianEngine? = null

    companion object {
        fun startService(context: Context) {
            val intent = Intent(context, GuardianService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "GuardianService created")
        
        createNotificationChannel()
        
        val notification = NotificationCompat.Builder(this, "guardian_channel")
            .setContentTitle("Druvatara Guardian")
            .setContentText("Protecting your family")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .build()
        
        startForeground(1, notification)
        
        guardianEngine = GuardianEngine.initialize(this, scope)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "guardian_channel",
                "Guardian Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Background service for Druvatara Guardian"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "GuardianService destroyed")
        guardianEngine?.shutdown()
        scope.cancel()
    }
}