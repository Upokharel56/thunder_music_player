package com.example.thunder_audio_player

import io.flutter.embedding.android.FlutterFragmentActivity
import android.os.Bundle

import com.ryanheise.audioservice.AudioServiceActivity;


class MainActivity : AudioServiceActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Additional initialization if needed
    }
}
