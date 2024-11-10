package dev.snaply.flutter_android.media_manager.video

import android.app.Activity
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import androidx.annotation.RequiresApi

/**
 * Utility class for handling screen metrics across different Android versions.
 * Provides compatibility layer for getting screen dimensions on Android R and below.
 */
object ScreenMetricsUtils {

    private const val LOG_TAG = "ScreenMetricsUtils"

    /**
     * API version-specific implementation for getting screen metrics.
     * Uses [ApiLevel30] for Android R and above, falls back to [Api] for older versions.
     */
    private val api: Api =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) ApiLevel30()
        else Api()

    /**
     * Gets screen metrics for the given activity.
     * Throws exception if metrics are invalid or cannot be retrieved.
     *
     * @param activity Activity to get metrics from
     * @return DisplayMetrics object with screen dimensions and density
     * @throws IllegalStateException if metrics are invalid or cannot be retrieved
     */
    fun getMetrics(activity: Activity): DisplayMetrics {
        try {
            val metrics = api.getScreenSize(activity)
            if (metrics.widthPixels <= 0 || metrics.heightPixels <= 0) {
                val size = "w=${metrics.widthPixels}, h=${metrics.heightPixels}"
                throw IllegalStateException("Invalid screen metrics: $size")
            }
            return metrics
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error getting screen metrics", e)
            throw IllegalStateException("Failed to get screen metrics", e)
        }
    }

    /**
     * Base implementation for getting screen metrics.
     * Uses deprecated WindowManager.getDefaultDisplay() for Android Q and below.
     */
    private open class Api {
        open fun getScreenSize(activity: Activity): DisplayMetrics {
            val metrics = DisplayMetrics()
            try {
                val display = activity.windowManager.defaultDisplay
                    ?: throw IllegalStateException("Default display is null")
                display.getMetrics(metrics)
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error in Api.getScreenSize", e)
                throw e
            }
            return metrics
        }
    }

    /**
     * Android R (API 30) specific implementation for getting screen metrics.
     * Uses Activity.getDisplay() which provides more accurate metrics.
     */
    private class ApiLevel30 : Api() {
        @RequiresApi(Build.VERSION_CODES.R)
        override fun getScreenSize(activity: Activity): DisplayMetrics {
            val metrics = DisplayMetrics()
            try {
                val display = activity.display
                    ?: throw IllegalStateException("Display is null")
                display.getRealMetrics(metrics)
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error in ApiLevel30.getScreenSize", e)
                throw e
            }
            return metrics
        }
    }
} 