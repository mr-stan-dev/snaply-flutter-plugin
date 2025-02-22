package dev.snaply.flutter_android.media_manager.video

import android.util.DisplayMetrics

object VideoScaleUtils {
    private const val DEFAULT_SCALE = 0.5

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