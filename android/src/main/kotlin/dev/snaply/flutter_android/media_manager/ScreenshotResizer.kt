package dev.snaply.flutter_android.media_manager

import android.util.Log
import android.util.Size

class ScreenshotResizer {
    companion object {
        private const val LOG_TAG = "ScreenshotResizer"
        // Maximum dimension for either width or height to optimize image size
        private const val MAX_SIDE_SIZE = 960
        // Minimum dimension threshold below which no scaling is needed
        private const val MIN_SIDE_SIZE = 240

        fun getResized(originalWidth: Int, originalHeight: Int): Pair<Int, Int> {
            try {
                Log.d(LOG_TAG, "Original screenshot: ${originalWidth}x${originalHeight}")

                // If both dimensions are smaller than minimum, keep original size
                if (originalWidth <= MIN_SIDE_SIZE && originalHeight <= MIN_SIDE_SIZE) {
                    Log.d(LOG_TAG, "Screenshot below minimum threshold, keeping original size")
                    return originalWidth to originalHeight
                }

                // Calculate scaled dimensions while preserving aspect ratio
                val aspectRatio = originalWidth.toFloat() / originalHeight.toFloat()
                var scaledWidth: Int
                var scaledHeight: Int

                if (aspectRatio > 1) {
                    // Landscape orientation
                    scaledWidth = MAX_SIDE_SIZE
                    scaledHeight = (scaledWidth / aspectRatio).toInt()
                } else {
                    // Portrait orientation
                    scaledHeight = MAX_SIDE_SIZE
                    scaledWidth = (scaledHeight * aspectRatio).toInt()
                }

                // Ensure dimensions are even numbers for better compression
                scaledWidth += scaledWidth % 2
                scaledHeight += scaledHeight % 2

                Log.d(LOG_TAG, "Scaled screenshot: ${scaledWidth}x${scaledHeight}")
                return scaledWidth to scaledHeight
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error scaling screenshot dimensions: ${e.message}")
                throw e
            }
        }
    }
} 