package com.example.thunder_audio_player

import android.os.Bundle
import android.util.Log
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.thunder_audio_player.handlers.VolumeHandler



class MainActivity : AudioServiceActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val VOLUME_CHANNEL = "com.example.app/volume"
    }

    private lateinit var volumeHandler: VolumeHandler


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initializeHandlers()
    }

    private fun initializeHandlers() {
        try {
            volumeHandler = VolumeHandler(this)
           
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing handlers", e)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupVolumeChannel(flutterEngine)
        
    }

    private fun setupVolumeChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOLUME_CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "volumeUp" -> {
                            volumeHandler.adjustVolumeUp()
                            result.success(null)
                        }
                        "volumeDown" -> {
                            volumeHandler.adjustVolumeDown()
                            result.success(null)
                        }
                        "setVolume" -> {
                            val volume = call.arguments<Double>()?.toFloat() ?: 0.5f
                            volumeHandler.setVolume(volume)
                            result.success(null)
                        }
                        "showVolumeSlider" -> {
                            volumeHandler.showVolumeSlider()
                            result.success(null)
                        }
                        "getVolume" -> {
                            result.success(volumeHandler.getCurrentVolume())
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error in volume channel", e)
                    result.error("VOLUME_ERROR", e.message, null)
                }
            }

    }


   






}