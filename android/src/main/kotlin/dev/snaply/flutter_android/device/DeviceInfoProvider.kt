package dev.snaply.flutter_android.device

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import android.util.Log

class DeviceInfoProvider {
    companion object {
        private const val LOG_TAG = "DeviceInfoProvider"
        private const val BYTES_IN_GB = 1024.0 * 1024 * 1024

        private fun formatGigabytes(bytes: Long): String {
            val gb = bytes / BYTES_IN_GB
            return "%.1f GB".format(gb)
        }

        fun getDeviceInfo(activity: Activity): Map<String, Map<String, String>> {
            try {
                val displayMetrics = activity.resources.displayMetrics
                val connectivityManager = activity.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                
                val activeNetwork = connectivityManager.activeNetwork
                val networkCapabilities = connectivityManager.getNetworkCapabilities(activeNetwork)
                
                // Determine network type
                val networkType = when {
                    networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true -> "WIFI"
                    networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true -> "CELLULAR"
                    networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) == true -> "ETHERNET"
                    networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true -> "VPN"
                    else -> "UNKNOWN"
                }

                val result = mutableMapOf<String, Map<String, String>>()

                // Device info
                result["device"] = mapOf(
                    "os" to "Android",
                    "os_version" to Build.VERSION.RELEASE,
                    "sdk_version" to Build.VERSION.SDK_INT.toString(),
                    "manufacturer" to Build.MANUFACTURER,
                    "model" to Build.MODEL,
                    "brand" to Build.BRAND,
                )

                // System info
                try {
                    val stat = StatFs(Environment.getExternalStorageDirectory().path)
                    val blockSize = stat.blockSizeLong
                    val totalBlocks = stat.blockCountLong
                    val availableBlocks = stat.availableBlocksLong

                    val activityManager = activity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val memInfo = ActivityManager.MemoryInfo()
                    activityManager.getMemoryInfo(memInfo)

                    result["system"] = mapOf(
                        "is_emulator" to (Build.FINGERPRINT.contains("generic") || 
                                     Build.PRODUCT.contains("sdk")).toString(),
                        "total_memory" to formatGigabytes(memInfo.totalMem),
                        "free_memory" to formatGigabytes(memInfo.availMem),
                        "available_processors" to Runtime.getRuntime().availableProcessors().toString(),
                        "storage_max" to formatGigabytes(blockSize * totalBlocks),
                        "storage_available" to formatGigabytes(blockSize * availableBlocks),
                        "android_version" to Build.VERSION.RELEASE,
                        "android_sdk" to Build.VERSION.SDK_INT.toString(),
                    )
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Error getting system info: ${e.message}")
                }

                // Locale info
                try {
                    result["locale"] = mapOf(
                        "language" to activity.resources.configuration.locales[0].language,
                        "country" to activity.resources.configuration.locales[0].country
                    )
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Error getting locale info: ${e.message}")
                }

                // Screen info
                try {
                    result["screen"] = mapOf(
                        "width" to displayMetrics.widthPixels.toString(),
                        "height" to displayMetrics.heightPixels.toString(),
                        "density" to displayMetrics.density.toString(),
                        "dpi" to displayMetrics.densityDpi.toString()
                    )
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Error getting screen info: ${e.message}")
                }

                // Network info
                result["network"] = mapOf(
                    "type" to networkType,
                    "is_available" to (networkCapabilities != null).toString()
                )

                return result
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error getting device info: ${e.message}")
                throw e
            }
        }
    }
} 