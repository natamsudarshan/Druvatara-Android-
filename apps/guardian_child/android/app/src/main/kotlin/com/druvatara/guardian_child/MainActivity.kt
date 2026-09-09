package com.druvatara.guardian_child

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import com.druvatara.guardian.engine.GuardianEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Initialize Guardian Engine
        GuardianEngine.initialize(this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Ensure Guardian Engine is initialized
        GuardianEngine.initialize(this)
    }

    override fun onDestroy() {
        super.onDestroy()
        GuardianEngine.getInstance()?.shutdown()
    }
}