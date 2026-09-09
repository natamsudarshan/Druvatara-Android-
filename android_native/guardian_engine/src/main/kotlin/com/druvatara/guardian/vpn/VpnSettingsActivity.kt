package com.druvatara.guardian.vpn

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class VpnSettingsActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val textView = TextView(this).apply {
            text = "VPN Settings"
            textSize = 24f
            gravity = android.view.Gravity.CENTER
            setPadding(32, 32, 32, 32)
        }
        setContentView(textView)
    }
}