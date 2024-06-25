package com.example.retro_launcher

import android.graphics.Color
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode.transparent

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        intent.putExtra("background_mode", transparent.toString())
        super.onCreate(savedInstanceState)
        window.statusBarColor = Color.TRANSPARENT;
        window.navigationBarColor = Color.TRANSPARENT;
    }
}
