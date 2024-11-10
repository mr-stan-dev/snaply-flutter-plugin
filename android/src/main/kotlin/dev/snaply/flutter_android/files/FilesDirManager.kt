package dev.snaply.flutter_android.files

import android.content.Context
import java.io.File

/**
 * Handles file operations and sharing functionality.
 */
class FilesDirManager {
    companion object {
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
}