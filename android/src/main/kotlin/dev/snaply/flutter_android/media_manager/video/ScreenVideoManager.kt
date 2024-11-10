package dev.snaply.flutter_android.media_manager.video

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import dev.snaply.flutter_android.files.FilesDirManager
import java.io.File

/**
 * Handles screen recording functionality using Android's MediaProjection API.
 */
class ScreenVideoManager {
    private val filesDirManager = FilesDirManager()

    private var screenDensity: Int = 0
    private var mediaRecorder: MediaRecorder? = null
    private var mediaProjectionManager: MediaProjectionManager? = null
    private var mediaProjection: MediaProjection? = null
    private var mediaProjectionCallback: MediaProjectionCallback? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var videoWidth: Int = 0
    private var videoHeight: Int = 0
    private var fileName: String? = null

    /**
     * Initiates the screen recording setup process and requests necessary permissions.
     * 
     * This method:
     * 1. Creates MediaProjectionManager and MediaRecorder
     * 2. Configures recording parameters based on screen metrics
     * 3. Sets up temporary file for recording
     * 4. Requests screen capture permission from user
     * 
     * @param activity The activity used to request permissions and access system services
     * @param scaleFactor Optional scale factor to override the default calculation. Range: 0.1 to 1.0
     * @throws IllegalStateException if external storage is not available
     */
    fun setupAndRequestRecording(
        activity: Activity,
        scaleFactor: Double? = null
    ) {
        if (activity.isFinishing) {
            Log.e(LOG_TAG, "Cannot start recording - Activity is finishing")
            return
        }

        try {
            mediaProjectionManager = createMediaProjectionManager(activity)
            mediaRecorder = createMediaRecorder(activity)

            val metrics = ScreenMetricsUtils.getMetrics(activity)
            Log.d(LOG_TAG, "Screen metrics obtained - width: ${metrics.widthPixels}, height: ${metrics.heightPixels}, density: ${metrics.densityDpi}")

            screenDensity = metrics.densityDpi
            val calculatedScale = scaleFactor ?: VideoScaleUtils.getScaleFactor(metrics)
            videoWidth = (metrics.widthPixels * calculatedScale).toInt()
            videoHeight = (metrics.heightPixels * calculatedScale).toInt()
            Log.d(LOG_TAG, "Video size calculated - width: $videoWidth, height: $videoHeight (scale: $calculatedScale)")

            setupFileName(activity)
            setupMediaRecorder()

            val permissionIntent = mediaProjectionManager?.createScreenCaptureIntent()
            Log.d(LOG_TAG, "Requesting screen capture permission")
            ActivityCompat.startActivityForResult(activity, permissionIntent!!, SCREEN_RECORD_REQUEST_CODE, null)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to setup screen recording", e)
            cleanup()
        }
    }

    /**
     * Sets up the file path for storing the screen recording.
     * 
     * Creates a temporary file in the app's external cache directory.
     * If a previous recording exists, it will be deleted.
     * 
     * @param activity The activity used to access external storage
     * @throws IllegalStateException if external cache directory is not available
     */
    private fun setupFileName(activity: Activity) {
        try {
            val reportCacheDir = filesDirManager.getSnaplyFilesDir(activity)
            
            val videoName = "screen_recording"
            fileName = "${reportCacheDir.absolutePath}/$videoName.mp4"

            val file = File(fileName!!)
            if (file.exists()) {
                file.delete()
                Log.d(LOG_TAG, "Deleted existing video file: $fileName")
            }

            Log.d(LOG_TAG, "Video file path set: $fileName")
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to setup video file path", e)
            throw e
        }
    }

    /**
     * Configures the MediaRecorder with video recording parameters.
     * 
     * Sets up:
     * - Video source (Surface)
     * - Output format (MPEG_4)
     * - Video encoder (H264)
     * - Frame rate (24 fps)
     * - Video size (based on screen metrics)
     * - Bitrate (dynamic, based on resolution)
     * 
     * Note: Order of MediaRecorder configuration is important
     */
    private fun setupMediaRecorder() {
        try {
            Log.d(LOG_TAG, "Configuring MediaRecorder with video size: ${videoWidth}x${videoHeight}")
            mediaRecorder?.apply {
                setVideoSource(MediaRecorder.VideoSource.SURFACE)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setOutputFile(fileName)
                setVideoEncoder(MediaRecorder.VideoEncoder.H264)
                setVideoSize(videoWidth, videoHeight)
                setVideoFrameRate(DEFAULT_FRAME_RATE)
                val bitRate = videoWidth * videoHeight * 4
                setVideoEncodingBitRate(bitRate)
                Log.d(LOG_TAG, "MediaRecorder configured - framerate: 24, bitrate: $bitRate")

                try {
                    prepare()
                    Log.d(LOG_TAG, "MediaRecorder prepared successfully")
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Failed to prepare MediaRecorder", e)
                    return
                }

                try {
                    start()
                    Log.d(LOG_TAG, "MediaRecorder started successfully")
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Failed to start MediaRecorder", e)
                }
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to setup MediaRecorder", e)
        }
    }

    fun onServiceStarted(resultCode: Int, data: Intent) {
        Log.d(LOG_TAG, "Service started - setting up media projection")
        mediaProjectionCallback = MediaProjectionCallback()
        mediaProjection = mediaProjectionManager?.getMediaProjection(resultCode, data)
        mediaProjection?.registerCallback(mediaProjectionCallback!!, null)
        virtualDisplay = createVirtualDisplay()
        Log.d(LOG_TAG, "Media projection setup complete")
    }

    /**
     * Stops the current screen recording and releases resources.
     *
     * @return Path to the recorded video file, or null if recording failed
     */
    fun stopScreenRecording(): String? {
        try {
            Log.d(LOG_TAG, "Stopping screen recording")
            mediaRecorder?.apply {
                try {
                    stop()
                    reset()
                    release()
                    Log.d(LOG_TAG, "Screen recording stopped successfully - File: $fileName")
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Failed to stop MediaRecorder", e)
                } finally {
                    mediaRecorder = null
                    stopMediaProjection()
                }
            }
            return fileName
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to stop screen recording", e)
        }
        return null
    }

    /**
     * Creates a MediaRecorder instance appropriate for the device's API level.
     * 
     * @param activity The activity context
     * @return MediaRecorder instance
     */
    private fun createMediaRecorder(activity: Activity): MediaRecorder {
        Log.d(LOG_TAG, "createMediaRecorder")
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            MediaRecorder(activity)
        } else {
            MediaRecorder()
        }
    }

    private fun createMediaProjectionManager(act: Activity): MediaProjectionManager? {
        Log.d(LOG_TAG, "createMediaProjectionManager")
        return act.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as? MediaProjectionManager
    }

    private fun createVirtualDisplay(): VirtualDisplay? {
        Log.d(LOG_TAG, "createVirtualDisplay")
        try {
            val surface = mediaRecorder?.surface
                ?: throw IllegalStateException("MediaRecorder surface is null")

            if (!surface.isValid) {
                throw IllegalStateException("Surface is not valid")
            }

            return mediaProjection?.createVirtualDisplay(
                "Snaply Virtual Display",
                videoWidth,
                videoHeight,
                screenDensity,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                surface,
                null,
                null,
            )
        } catch (e: Exception) {
            Log.e(LOG_TAG, "createVirtualDisplay error: $e")
            return null
        }
    }

    private fun stopMediaProjection() {
        Log.d(LOG_TAG, "stopScreenSharing")
        try {
            virtualDisplay?.release()
            virtualDisplay = null

            mediaProjectionCallback?.let {
                mediaProjection?.unregisterCallback(it)
            }
            mediaProjectionCallback = null

            mediaProjection?.stop()
            mediaProjection = null
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error in stopMediaProjection: $e")
        }
    }

    private fun cleanup() {
        mediaRecorder?.release()
        mediaRecorder = null
        stopMediaProjection()
    }

    inner class MediaProjectionCallback : MediaProjection.Callback() {
        override fun onStop() {
            Log.d(LOG_TAG, "Media projection stopped by system or user")
            mediaRecorder?.reset()
            stopMediaProjection()
        }
    }

    companion object {
        /** Request code for screen capture permission */
        const val SCREEN_RECORD_REQUEST_CODE = 42
        private const val LOG_TAG = "ScreenRecordManager"
        private const val DEFAULT_FRAME_RATE = 24
    }
}