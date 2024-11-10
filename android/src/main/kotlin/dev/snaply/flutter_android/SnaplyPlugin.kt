package dev.snaply.flutter_android

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.telephony.TelephonyManager
import android.util.Log
import dev.snaply.flutter_android.files.FilesDirManager
import dev.snaply.flutter_android.files.FilesSharingManager
import dev.snaply.flutter_android.media_manager.ScreenshotManager
import dev.snaply.flutter_android.media_manager.service.SnaplyForegroundService
import dev.snaply.flutter_android.media_manager.video.ScreenVideoManager
import dev.snaply.flutter_android.media_manager.video.ScreenVideoManager.Companion.SCREEN_RECORD_REQUEST_CODE
import dev.snaply.flutter_android.device.DeviceInfoProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.renderer.FlutterRenderer
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/**
 *
 * This plugin provides three main functionalities:
 * 1. Taking screenshots of the Flutter UI
 * 2. Starting screen recording with user permission
 * 3. Stopping screen recording and saving the video file
 *
 * The plugin manages its lifecycle with the Flutter engine and Android activity,
 * ensuring proper resource cleanup and state management.
 */
class SnaplyPlugin : FlutterPlugin, MethodCallHandler, PluginRegistry.ActivityResultListener,
    ActivityAware {

    private var screenVideoManager: ScreenVideoManager? = null
    private var screenshotManager: ScreenshotManager? = null
    private var fileManager: FilesSharingManager? = null

    private var activityBinding: ActivityPluginBinding? = null
    private var renderer: FlutterRenderer? = null

    /**
     * Current activity reference. Throws [IllegalStateException] if accessed when activity is not attached.
     */
    private val activity: Activity
        get() = activityBinding?.activity ?: throw IllegalStateException("Activity is not attached")

    /**
     * Method channel for Flutter-Android communication.
     * Initialized in [onAttachedToEngine] and cleaned up in [onDetachedFromEngine].
     */
    private var channel: MethodChannel? = null

    /**
     * Stores pending result for async operations like screen recording permission request.
     */
    private var pendingResult: Result? = null

    /**
     * Handles method calls from Flutter.
     * Supported methods:
     * - [TAKE_SCREENSHOT_METHOD]: Takes a screenshot of current Flutter UI
     * - [START_SCREEN_RECORDING_METHOD]: Starts screen recording after permission
     * - [STOP_SCREEN_RECORDING_METHOD]: Stops current recording and returns file path
     * - [SHARE_FILES_METHOD]: Shares files with the app
     * - [GET_SNAPLY_DIRECTORY_METHOD]: Returns the Snaply directory
     * - [GET_DEVICE_INFO_METHOD]: Returns device information
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(LOG_TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            TAKE_SCREENSHOT_METHOD -> handleTakeScreenshot(result)
            START_SCREEN_RECORDING_METHOD -> handleStartScreenRecording(result)
            STOP_SCREEN_RECORDING_METHOD -> handleStopScreenRecording(result)
            SHARE_FILES_METHOD -> handleShareFiles(call, result)
            GET_SNAPLY_DIRECTORY_METHOD -> handleGetSnaplyDirectory(result)
            GET_DEVICE_INFO_METHOD -> handleGetDeviceInfo(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Takes a screenshot of the current Flutter UI.
     * Requires initialized [renderer] and [screenshotManager].
     */
    private fun handleTakeScreenshot(result: Result) {
        try {
            val bitmap = (renderer as FlutterRenderer).bitmap
            val bytes = screenshotManager?.processScreenshot(bitmap)
            if (bytes != null) {
                result.success(bytes)
            } else {
                result.error(
                    TAKE_SCREENSHOT_METHOD,
                    "$TAKE_SCREENSHOT_METHOD error: bytes is null",
                    null,
                )
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Screenshot error: ${e.message}")
            result.error(
                TAKE_SCREENSHOT_METHOD,
                "$TAKE_SCREENSHOT_METHOD error: $e",
                null,
            )
        }
    }

    /**
     * Starts screen recording process.
     * This will trigger permission request and foreground service setup.
     */
    private fun handleStartScreenRecording(result: Result) {
        try {
            screenVideoManager?.setupAndRequestRecording(activity)
                ?: throw IllegalStateException("ScreenRecordApi is not initialized")
            pendingResult = result
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Start recording error: ${e.message}")
            result.error(
                START_SCREEN_RECORDING_METHOD,
                "$START_SCREEN_RECORDING_METHOD error: $e",
                null,
            )
        }
    }

    /**
     * Stops current screen recording and returns the recorded video file path.
     */
    private fun handleStopScreenRecording(result: Result) {
        try {
            SnaplyForegroundService.stopService(activity)
            val path = screenVideoManager?.stopScreenRecording()
            if (path != null) {
                result.success(path)
            } else {
                result.error(
                    STOP_SCREEN_RECORDING_METHOD,
                    "$STOP_SCREEN_RECORDING_METHOD error: path is null",
                    null,
                )
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Stop recording error: ${e.message}")
            result.error(
                STOP_SCREEN_RECORDING_METHOD,
                "$STOP_SCREEN_RECORDING_METHOD error: $e",
                null,
            )
        }
    }

    /**
     * Handles new method call
     */
    private fun handleShareFiles(call: MethodCall, result: Result) {
        try {
            val filePaths = call.argument<List<String>>("filePaths")
            if (filePaths != null) {
                val chooserIntent = fileManager?.createShareChooserIntent(activity, filePaths)
                if (chooserIntent != null) {
                    activity.startActivity(chooserIntent)
                    result.success(null)
                } else {
                    result.error(
                        SHARE_FILES_METHOD,
                        "$SHARE_FILES_METHOD error: chooserIntent is null",
                        null,
                    )
                }
            } else {
                result.error(
                    SHARE_FILES_METHOD,
                    "$SHARE_FILES_METHOD filePaths argument is required",
                    null
                )
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Share file error: ${e.message}")
            result.error(
                SHARE_FILES_METHOD,
                "$SHARE_FILES_METHOD error: $e",
                null,
            )
        }
    }

    /**
     * Returns the Snaply directory for storing report files
     */
    private fun handleGetSnaplyDirectory(result: Result) {
        try {
            val reportCacheDir = FilesDirManager().getSnaplyFilesDir(activity)
            Log.d(LOG_TAG, "reportCacheDir: ${reportCacheDir.absolutePath}")
            result.success(reportCacheDir.absolutePath)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Get Snaply directory error: ${e.message}")
            result.error(
                GET_SNAPLY_DIRECTORY_METHOD,
                "$GET_SNAPLY_DIRECTORY_METHOD error: $e",
                null,
            )
        }
    }

    /**
     * Returns device information including OS version, SDK version, manufacturer,
     * model name, screen resolution, and network connectivity state
     */
    private fun handleGetDeviceInfo(result: Result) {
        try {
            val deviceInfo = DeviceInfoProvider.getDeviceInfo(activity)
            result.success(deviceInfo)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Get device info error: ${e.message}")
            result.error(
                GET_DEVICE_INFO_METHOD,
                "$GET_DEVICE_INFO_METHOD error: $e",
                null,
            )
        }
    }

    /**
     * Handles activity result for screen recording permission request.
     * Called after user grants or denies screen recording permission.
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.d(LOG_TAG, "onActivityResult, requestCode: $requestCode")
        if (requestCode != SCREEN_RECORD_REQUEST_CODE) {
            return false
        }

        if (resultCode == Activity.RESULT_OK && data != null) {
            startForegroundService(resultCode, data)
        } else {
            handleScreenRecordingPermissionDenied()
        }
        return true
    }

    /**
     * Starts foreground service for screen recording.
     * Must be called after receiving screen recording permission.
     */
    private fun startForegroundService(resultCode: Int, data: Intent) {
        /**
         * The foreground service needs to be started only after
         * receiving the screen share permission,
         * but before the screen share is actually started.
         */
        try {
            SnaplyForegroundService.requestStart(
                activity = activity,
                onStarted = {
                    Log.d(LOG_TAG, "SnaplyForegroundService.onStarted")
                    screenVideoManager?.onServiceStarted(resultCode, data)
                    pendingResult?.success(true)
                },
                onPermissionsDenied = {
                    val errorMsg =
                        "$START_SCREEN_RECORDING_METHOD permission not added to Manifest"
                    Log.e(LOG_TAG, errorMsg)
                    pendingResult?.error(START_SCREEN_RECORDING_METHOD, errorMsg, null)
                }
            )
        } catch (e: Exception) {
            val errorMsg =
                "$START_SCREEN_RECORDING_METHOD Error: $e"
            Log.e(LOG_TAG, errorMsg)
            pendingResult?.error(START_SCREEN_RECORDING_METHOD, errorMsg, null)
        }
    }

    /**
     * Handles case when user denies screen recording permission.
     */
    private fun handleScreenRecordingPermissionDenied() {
        val errorMsg = "Media projection runtime permissions not granted"
        Log.e(LOG_TAG, errorMsg)
        pendingResult?.error(
            START_SCREEN_RECORDING_METHOD,
            errorMsg,
            null,
        )
    }

    // Activity Lifecycle Methods

    /**
     * Called when plugin is attached to an Android Activity.
     * Initializes APIs and sets up activity result listener.
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        activityBinding?.addActivityResultListener(this)
        screenVideoManager = ScreenVideoManager()
        screenshotManager = ScreenshotManager()
        fileManager = FilesSharingManager()
    }

    /**
     * Called when plugin is detached from Android Activity.
     * Cleans up resources and listeners.
     */
    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        screenVideoManager = null
        screenshotManager = null
        fileManager = null
    }

    // Configuration Change Handling

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    // Flutter Engine Lifecycle Methods

    /**
     * Called when plugin is attached to Flutter engine.
     * Sets up method channel and renderer.
     */
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
        renderer = binding.textureRegistry as? FlutterRenderer
    }

    /**
     * Called when plugin is detached from Flutter engine.
     * Cleans up all resources.
     */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        renderer = null
        pendingResult = null
    }

    companion object {
        private const val LOG_TAG = "SnaplyPlugin"
        private const val METHOD_CHANNEL_NAME = "SnaplyMethodChannel"

        /** Method channel method names */
        private const val TAKE_SCREENSHOT_METHOD = "takeScreenshotMethod"
        private const val START_SCREEN_RECORDING_METHOD = "startScreenRecordingMethod"
        private const val STOP_SCREEN_RECORDING_METHOD = "stopScreenRecordingMethod"
        private const val SHARE_FILES_METHOD = "shareFilesMethod"
        private const val GET_SNAPLY_DIRECTORY_METHOD = "getSnaplyDirectoryMethod"
        private const val GET_DEVICE_INFO_METHOD = "getDeviceInfoMethod"
    }
}