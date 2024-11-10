package dev.snaply.flutter_android.media_manager

import android.graphics.Bitmap
import android.util.Log
import java.io.ByteArrayOutputStream
import java.io.IOException

/**
 * API for processing and compressing screenshots.
 * Handles bitmap resizing and compression.
 */
class ScreenshotManager {
    companion object {
        private const val LOG_TAG = "ScreenshotManager"
        private const val MAX_SIDE_SIZE = 960
        private const val MIN_SIDE_SIZE = 240
        private const val DEFAULT_QUALITY = 40
    }

    /**
     * Processes a bitmap screenshot.
     * The image is:
     * 1. Resized if larger than MAX_SIDE_SIZE
     * 2. Compressed as WebP format
     *
     * @param bitmap Source bitmap to process
     * @param quality Compression quality (1-100), defaults to COMPRESSION_QUALITY
     * @return Byte array of compressed WebP image, or null if processing fails
     */
    fun processScreenshot(
        bitmap: Bitmap,
        quality: Int = DEFAULT_QUALITY
    ): ByteArray? {
        Log.d(LOG_TAG, "Processing screenshot with quality: $quality")
        return try {
            // Validate bitmap dimensions
            if (bitmap.width <= 0 || bitmap.height <= 0) {
                throw IllegalStateException("Invalid bitmap dimensions: ${bitmap.width}x${bitmap.height}")
            }

            val resizedBitmap = getResizedBitmap(bitmap)
            compressBitmap(resizedBitmap, quality)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to process screenshot: ${e.message}")
            null
        }
    }

    /**
     * Resizes bitmap while maintaining aspect ratio.
     * Ensures dimensions are even numbers for better compression.
     *
     * @param image Original bitmap to resize
     * @return Resized bitmap, or original if already within size limits
     * @throws Exception if resizing fails
     */
    private fun getResizedBitmap(image: Bitmap): Bitmap {
        try {
            var width = image.width
            var height = image.height
            Log.d(LOG_TAG, "Original bitmap: ${width}x${height}")

            if (width <= MIN_SIDE_SIZE && height <= MIN_SIDE_SIZE) {
                Log.d(LOG_TAG, "Bitmap too small, using original size")
                return image
            }

            // Calculate new dimensions maintaining aspect ratio
            val bitmapRatio = width.toFloat() / height.toFloat()
            if (bitmapRatio > 1) {
                // Landscape
                width = MAX_SIDE_SIZE
                height = (width / bitmapRatio).toInt()
            } else {
                // Portrait
                height = MAX_SIDE_SIZE
                width = (height * bitmapRatio).toInt()
            }

            // Ensure dimensions are even numbers for better compression
            width += width % 2
            height += height % 2

            Log.d(LOG_TAG, "Resized bitmap: ${width}x${height}")
            return Bitmap.createScaledBitmap(image, width, height, true)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error resizing bitmap: ${e.message}")
            throw e
        }
    }

    /**
     * Compresses bitmap to WebP format.
     * Uses COMPRESSION_QUALITY for size optimization.
     *
     * @param bitmap Bitmap to compress
     * @param quality Compression quality (1-100)
     * @return Compressed image as byte array
     * @throws Exception if compression fails
     */
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