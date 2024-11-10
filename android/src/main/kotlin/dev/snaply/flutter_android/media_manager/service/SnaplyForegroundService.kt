package dev.snaply.flutter_android.media_manager.service

import android.Manifest
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import dev.snaply.flutter_android.R

/**
 * A foreground service for handling screen recording functionality.
 * This service ensures the screen recording continues even when the app is in the background.
 *
 * On Android 14+ (UPSIDE_DOWN_CAKE), this service requires the following permissions:
 * - android.permission.FOREGROUND_SERVICE
 * - android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION
 */
class SnaplyForegroundService : Service() {

    companion object {
        private const val LOG_TAG = "SnaplyForegroundService"
        private const val CHANNEL_ID = "snaply_notification_channel"
        private const val CHANNEL_NAME = "Screen Recording"
        private const val NOTIFICATION_ID = 1
        private const val PENDING_INTENT_FLAGS = PendingIntent.FLAG_IMMUTABLE

        private var onStarted: (() -> Unit)? = null

        /**
         * Requests to start the foreground service.
         *
         * @param activity The activity context used to start the service
         * @param onStarted Callback invoked when the service successfully starts
         * @param onPermissionsDenied Callback invoked when required permissions are not granted
         */
        fun requestStart(
            activity: Activity,
            onStarted: (() -> Unit),
            onPermissionsDenied: (() -> Unit),
        ) {
            Log.d(LOG_TAG, "requestStart")
            try {
                if (!hasPermission(activity)) {
                    Log.d(LOG_TAG, "Missing required permissions")
                    onPermissionsDenied.invoke()
                    return
                }

                val serviceIntent = Intent(activity, SnaplyForegroundService::class.java)
                try {
                    // Try to resolve the service intent first
                    if (activity.packageManager.resolveService(serviceIntent, 0) == null) {
                        throw IllegalStateException(
                            "Service ${SnaplyForegroundService::class.java.name} not found in manifest"
                        )
                    }
                    
                    ContextCompat.startForegroundService(activity, serviceIntent)
                    this.onStarted = onStarted
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Failed to start service: ${e.message}")
                    throw IllegalStateException("Failed to start SnaplyForegroundService", e)
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error in requestStart: ${e.message}")
                throw e
            }
        }

        /**
         * Stops the foreground service.
         *
         * @param context The context used to stop the service
         */
        fun stopService(context: Context) {
            try {
                val stopIntent = Intent(context, SnaplyForegroundService::class.java)
                context.stopService(stopIntent)
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error stopping service: ${e.message}")
            }
        }

        /**
         * Checks if the required foreground service permissions are granted.
         * Only applicable for Android 14+ (UPSIDE_DOWN_CAKE).
         */
        private fun hasPermission(activity: Activity): Boolean {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val servicePerm = Manifest.permission.FOREGROUND_SERVICE
                val mediaProjServicePerm = Manifest.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION
                isPermGranted(activity, servicePerm) && isPermGranted(activity, mediaProjServicePerm)
            } else {
                true
            }
        }

        /**
         * Checks if a specific permission is granted.
         *
         * @param activity The activity context to check permissions
         * @param permission The permission to check
         * @return true if permission is granted, false otherwise
         */
        private fun isPermGranted(activity: Activity, permission: String): Boolean {
            return try {
                ContextCompat.checkSelfPermission(
                    activity,
                    permission
                ) == PackageManager.PERMISSION_GRANTED
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error checking permission $permission: ${e.message}")
                false
            }
        }
    }

    /**
     * Called when the service is started. Creates notification channel and starts foreground service.
     */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(LOG_TAG, "onStartCommand")
        try {
            createNotificationChannel()
            val notification = buildNotification()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }

            onStarted?.invoke()
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error in onStartCommand: ${e.message}")
            stopSelf()
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent): IBinder? = null

    /**
     * Called when the service is destroyed. Cleans up resources and callbacks.
     */
    override fun onDestroy() {
        try {
            super.onDestroy()
            onStarted = null
            Log.d(LOG_TAG, "onDestroy")
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error in onDestroy: ${e.message}")
        }
    }

    /**
     * Builds the notification shown while the service is running.
     *
     * @return A notification configured for foreground service
     * @throws Exception if notification creation fails
     */
    private fun buildNotification(): Notification {
        try {
            // Get the package's main activity
            val packageManager = applicationContext.packageManager
            val intent = packageManager.getLaunchIntentForPackage(applicationContext.packageName)
                ?: throw IllegalStateException("No launch intent for package")

            val pendingIntent = PendingIntent.getActivity(
                this,
                0,
                intent,
                PENDING_INTENT_FLAGS
            )

            return NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Screen Recording")
                .setContentText("Snaply is recording your screen")
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .setOngoing(true)
                .setSmallIcon(R.drawable.ic_screen_record)
                .setContentIntent(pendingIntent)
                .build()
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error building notification: ${e.message}")
            throw e
        }
    }

    /**
     * Creates the notification channel required for Android O and above.
     *
     * @throws Exception if channel creation fails
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Screen recording notification"
                    setShowBadge(false)
                    enableLights(false)
                    enableVibration(false)
                }

                val notificationManager = getSystemService(NotificationManager::class.java)
                    ?: throw IllegalStateException("NotificationManager is null")
                
                notificationManager.createNotificationChannel(channel)
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error creating notification channel: ${e.message}")
                throw e
            }
        }
    }
}