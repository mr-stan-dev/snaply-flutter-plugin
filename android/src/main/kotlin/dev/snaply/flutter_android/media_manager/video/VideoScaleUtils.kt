package dev.snaply.flutter_android.media_manager.video

import android.util.DisplayMetrics

/**
 * Utility class for calculating video scale factors for screen recording.
 * Determines appropriate scaling based on screen dimensions to optimize video size.
 */
object VideoScaleUtils {

    /**
     * Default scale factor used when calculation fails or dimensions are invalid.
     */
    private const val DEFAULT_SCALE = 0.5

    /**
     * Calculates optimal scale factor based on screen metrics.
     * Applies dynamic scaling based on screen size:
     * - For screens > 3600px: scales to 25%
     * - For screens > 2400px: scales to 40%
     * - For screens > 1200px: scales to 50%
     * - For smaller screens: no scaling
     *
     * @param metrics Display metrics containing screen dimensions
     * @return Scale factor to be applied to screen dimensions
     */
    fun getScaleFactor(metrics: DisplayMetrics): Double {
        if (metrics.widthPixels <= 0 || metrics.heightPixels <= 0) {
            return DEFAULT_SCALE
        }

        val maxSide = maxOf(metrics.widthPixels, metrics.heightPixels)
        return when {
            maxSide > 3600 -> 0.25
            maxSide > 2400 -> 0.4
            maxSide > 1200 -> 0.5
            else -> 1.0
        }
    }
}