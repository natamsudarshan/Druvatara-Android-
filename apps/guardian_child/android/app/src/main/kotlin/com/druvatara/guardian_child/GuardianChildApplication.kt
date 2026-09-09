package com.druvatara.guardian_child

import android.app.Application
import com.druvatara.guardian.engine.GuardianEngine
import com.google.firebase.FirebaseApp
import com.google.firebase.messaging.FirebaseMessaging

class GuardianChildApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // Initialize Firebase
        FirebaseApp.initializeApp(this)
        
        // Initialize Guardian Engine
        GuardianEngine.initialize(this)
        
        // Set up FCM token handling
        setupFCM()
    }

    private fun setupFCM() {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!task.isSuccessful) {
                return@addOnCompleteListener
            }
            val token = task.result
            // Send token to Flutter via MethodChannel
        }
    }
}