package com.druvatara.guardian.app_control

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class AppBlockedActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val packageName = intent.getStringExtra("package_name") ?: "Unknown app"
        val reason = intent.getStringExtra("reason") ?: "Blocked by parental controls"
        
        val textView = TextView(this).apply {
            text = "$packageName\n\n$reason"
            textSize = 20f
            gravity = android.view.Gravity.CENTER
            setPadding(32, 32, 32, 32)
        }
        setContentView(textView)
    }
}