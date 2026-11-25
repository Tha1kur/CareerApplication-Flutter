package com.careerguidance.flutter

import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        disableSoundEffects(window.decorView)
    }

    override fun onResume() {
        super.onResume()
        disableSoundEffects(window.decorView)
    }

    private fun disableSoundEffects(view: View) {
        view.isSoundEffectsEnabled = false
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) {
                disableSoundEffects(view.getChildAt(i))
            }
        }
    }
}
