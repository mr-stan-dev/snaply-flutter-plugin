package dev.snaply.flutter_android.files

import android.content.Context
import android.content.Intent
import androidx.core.content.FileProvider
import java.io.File

/**
 * Handles file operations and sharing functionality.
 */
class FilesSharingManager {

    /**
     * Creates and returns an intent for sharing files through system share sheet.
     *
     * @param context Application context
     * @param filePaths List of file paths to share
     * @return Ready-to-use chooser intent with proper flags
     * @throws IllegalStateException if files don't exist
     */
    fun createShareChooserIntent(context: Context, filePaths: List<String>): Intent {
        val intent = createShareIntent(context, filePaths)
        return Intent.createChooser(intent, "Share Report").apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
    }

    private fun getMimeType(file: File): String {
        return when (file.extension.lowercase()) {
            "jpg", "jpeg" -> "image/jpeg"
            "png" -> "image/png"
            "mp4" -> "video/mp4"
            "zip" -> "application/zip"
            "tar" -> "application/x-tar"
            "json" -> "application/json"
            "txt" -> "text/plain"
            else -> "*/*"
        }
    }

    private fun createShareIntent(context: Context, filePaths: List<String>): Intent {
        val files = filePaths.map { File(it) }
        if (files.any { !it.exists() }) {
            throw IllegalStateException("One or more files do not exist")
        }

        val authority = "${context.packageName}.snaply.fileprovider"

        val uris = files.map { file ->
            FileProvider.getUriForFile(context, authority, file)
        }

        val isSingleFile = files.size == 1
        return if (isSingleFile) {
            val extension = files.first().extension
            Intent(Intent.ACTION_SEND).apply {
                type = getMimeType(files.first())
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                putExtra(Intent.EXTRA_STREAM, uris.first())
                putExtra(Intent.EXTRA_SUBJECT, "snaply_report.$extension")
                putExtra(Intent.EXTRA_TITLE, "snaply_report.$extension")
            }
        } else {
            Intent(Intent.ACTION_SEND_MULTIPLE).apply {
                type = "*/*"
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                putParcelableArrayListExtra(Intent.EXTRA_STREAM, ArrayList(uris))
                putExtra(Intent.EXTRA_SUBJECT, "Snaply Report Files")
                putExtra(Intent.EXTRA_TITLE, "Snaply Report Files")
            }
        }
    }
}