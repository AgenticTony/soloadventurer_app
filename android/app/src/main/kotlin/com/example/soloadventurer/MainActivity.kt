package com.example.soloadventurer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import dev.flutter.workmanager.WorkManagerPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register workmanager callback dispatcher for background tasks
        flutterEngine.plugins.add(WorkManagerPlugin())
    }
}
