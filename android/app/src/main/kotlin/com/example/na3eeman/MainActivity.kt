package com.example.na3eeman

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * MainActivity
 *
 * Kept minimal — all global SDK initialization (Firebase, Facebook, etc.)
 * is done in [MainApplication] so it runs before any Activity is created.
 */
class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
