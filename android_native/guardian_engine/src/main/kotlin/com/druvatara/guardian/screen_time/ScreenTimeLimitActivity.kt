package com.druvatara.guardian.screen_time

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class ScreenTimeLimitActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val textView = TextView(this).apply {
            text = "Daily screen time limit reached"
            textSize = 24f
            gravity = android.view.Gravity.CENTER
            setPadding(32, 32, 32, 32)
        }
        setContentView(textView)
    }
}