package com.example.vector

import io.flutter.embedding.android.FlutterActivity
import com.yandex.mapkit.MapKitFactory
import android.os.Bundle

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Устанавливаем ключ ДО создания activity
        MapKitFactory.setApiKey("5981925b-c476-4dab-800c-906f0c940cdc")
        super.onCreate(savedInstanceState)
    }
}