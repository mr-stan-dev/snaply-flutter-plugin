package dev.snaply.flutter_android.files

import android.content.Context
import android.util.Log
import java.io.File

/**
 * Handles file operations and sharing functionality.
 */
class FilesManager {
    companion object {
        private const val LOG_TAG = "FilesManager"
        private const val SNAPLY_FILES_DIR = "snaply_files"
    }

    /**
     * Returns the directory for storing Snaply temporary files.
     * Creates the directory if it doesn't exist.
     *
     * @param context The context to get the external cache directory
     * @return The Snaply files directory
     * @throws IllegalStateException if external cache directory is not available
     */
    fun getSnaplyFilesDir(context: Context): File {
        val cacheDir = context.externalCacheDir
            ?: throw IllegalStateException("External cache directory not available")

        // Ensure base cache directory exists
        cacheDir.mkdirs()

        // Create and return snaply directory
        return File(cacheDir, SNAPLY_FILES_DIR).apply {
            mkdirs()  // Create snaply directory if it doesn't exist
        }
    }

    fun getVideoFile(context: Context): File {
        try {
            val filesDir = getSnaplyFilesDir(context)

            val fileName = "${filesDir.absolutePath}/screen_recording.mp4"

            val file = File(fileName)
            if (file.exists()) {
                file.delete()
                Log.d(LOG_TAG, "Deleted existing video file: $fileName")
            }

            Log.d(LOG_TAG, "Video file path set: $fileName")
            return file
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to setup video file path", e)
            throw e
        }
    }
}