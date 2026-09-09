package com.druvatara.guardian

import android.app.Application
import android.content.Context
import com.druvatara.guardian.engine.GuardianEngine
import com.druvatara.guardian.engine.GuardianService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

class GuardianApplication : Application() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var guardianEngine: GuardianEngine? = null

    override fun onCreate() {
        super.onCreate()

        // Initialize Guardian Engine
        guardianEngine = GuardianEngine.initialize(this, scope)

        // Start the main Guardian service
        GuardianService.startService(this)
    }

    fun getGuardianEngine(): GuardianEngine? = guardianEngine

    fun getCoroutineScope(): CoroutineScope = scope

    companion object {
        fun getInstance(context: Context): GuardianApplication {
            return context.applicationContext as GuardianApplication
        }
    }
}