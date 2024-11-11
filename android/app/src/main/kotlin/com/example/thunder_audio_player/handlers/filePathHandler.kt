// FilePathHandler.kt
package com.example.thunder_audio_player.handlers

import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.MediaStore
import android.util.Log

class FilePathHandler(private val context: Context) {
    companion object {
        private const val TAG = "FilePathHandler"
    }

    fun handleRealPath(uriString: String): String? {
        return try {
            getRealPathFromURI(Uri.parse(uriString))
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing URI: ${e.message}")
            null
        }
    }

    private fun getRealPathFromURI(contentUri: Uri): String? {
        val proj = arrayOf(MediaStore.Audio.Media.DATA)
        val cursor: Cursor? = context.contentResolver.query(contentUri, proj, null, null, null)
        cursor?.use {
            val columnIndex = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            it.moveToFirst()
            return it.getString(columnIndex)
        }
        return null
    }
}