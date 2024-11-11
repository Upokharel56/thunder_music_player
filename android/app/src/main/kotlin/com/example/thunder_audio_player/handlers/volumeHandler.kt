// VolumeHandler.kt
// VolumeHandler.kt
package com.example.thunder_audio_player.handlers

import android.content.Context
import android.media.AudioManager
import android.util.Log


class VolumeHandler(private val context: Context) {
    private val audioManager: AudioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    fun adjustVolumeUp() {
        try {
            audioManager.adjustVolume(AudioManager.ADJUST_RAISE, AudioManager.FLAG_PLAY_SOUND)
        } catch (e: Exception) {
            Log.e("VolumeHandler", "Error adjusting volume up", e)
        }
    }

    fun adjustVolumeDown() {
        try {
            audioManager.adjustVolume(AudioManager.ADJUST_LOWER, AudioManager.FLAG_PLAY_SOUND)
        } catch (e: Exception) {
            Log.e("VolumeHandler", "Error adjusting volume down", e)
        }
    }

    fun setVolume(volume: Float) {
        try {
            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            val targetVolume = (volume * maxVolume).toInt()
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVolume, 0)
        } catch (e: Exception) {
            Log.e("VolumeHandler", "Error setting volume", e)
        }
    }

    fun getCurrentVolume(): Float {
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        return currentVolume.toFloat() / maxVolume
    }

    fun showVolumeSlider() {
        audioManager.adjustVolume(AudioManager.ADJUST_SAME, AudioManager.FLAG_SHOW_UI)
    }
}

