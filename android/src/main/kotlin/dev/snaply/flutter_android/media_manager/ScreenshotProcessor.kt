package dev.snaply.flutter_android.media_manager

import android.graphics.Bitmap
import android.util.Log
import java.io.ByteArrayOutputStream
import java.io.IOException

class ScreenshotProcessor {
    companion object {
        private const val LOG_TAG = "ScreenshotProcessor"
        private const val DEFAULT_QUALITY = 40
    }

    fun process(
        bitmap: Bitmap,
        quality: Int = DEFAULT_QUALITY
    ): ByteArray? {
        Log.d(LOG_TAG, "Processing screenshot with quality: $quality")
        return try {
            val (width, height) = ScreenshotResizer.getResized(bitmap.width, bitmap.height)
            val resizedBitmap = Bitmap.createScaledBitmap(bitmap, width, height, true)
            compressBitmap(resizedBitmap, quality)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to process screenshot: ${e.message}")
            null
        }
    }

    private fun compressBitmap(bitmap: Bitmap, quality: Int): ByteArray {
        var outputStream: ByteArrayOutputStream? = null
        try {
            outputStream = ByteArrayOutputStream()
            if (!bitmap.compress(Bitmap.CompressFormat.WEBP, quality, outputStream)) {
                throw IOException("Failed to compress bitmap")
            }
            outputStream.flush()
            return outputStream.toByteArray()
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error compressing bitmap: ${e.message}")
            throw e
        } finally {
            try {
                outputStream?.close()
            } catch (e: IOException) {
                Log.e(LOG_TAG, "Error closing output stream: ${e.message}")
            }
        }
    }
}