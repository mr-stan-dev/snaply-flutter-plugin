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

class ScreenVideoRecorder {

    private var screenDensity: Int = 0
    private var mediaRecorder: MediaRecorder? = null
    private var mediaProjectionManager: MediaProjectionManager? = null
    private var mediaProjection: MediaProjection? = null
    private var mediaProjectionCallback: MediaProjectionCallback? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var videoWidth: Int = 0
    private var videoHeight: Int = 0
    private var filePath: String? = null

    fun requestRecording(
        activity: Activity,
        outputFilePath: String,
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
            val scaleFactor = VideoScaleUtils.getScaleFactor(metrics)
            videoWidth = (metrics.widthPixels * scaleFactor).toInt()
            videoHeight = (metrics.heightPixels * scaleFactor).toInt()
            Log.d(LOG_TAG, "Video size calculated - width: $videoWidth, height: $videoHeight (scale: $scaleFactor)")

            filePath = outputFilePath
            setupMediaRecorder()

            val permissionIntent = mediaProjectionManager?.createScreenCaptureIntent()
            Log.d(LOG_TAG, "Requesting screen capture permission")
            ActivityCompat.startActivityForResult(activity, permissionIntent!!, SCREEN_RECORD_REQUEST_CODE, null)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to setup screen recording", e)
            cleanup()
        }
    }

    private fun setupMediaRecorder() {
        try {
            Log.d(LOG_TAG, "Configuring MediaRecorder with video size: ${videoWidth}x${videoHeight}")
            mediaRecorder?.apply {
                setVideoSource(MediaRecorder.VideoSource.SURFACE)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setOutputFile(filePath)
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

    fun stopScreenRecording(): String? {
        try {
            Log.d(LOG_TAG, "Stopping screen recording")
            mediaRecorder?.apply {
                try {
                    stop()
                    reset()
                    release()
                    Log.d(LOG_TAG, "Screen recording stopped successfully - File: $filePath")
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Failed to stop MediaRecorder", e)
                } finally {
                    mediaRecorder = null
                    stopMediaProjection()
                }
            }
            return filePath
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to stop screen recording", e)
        }
        return null
    }

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
        const val SCREEN_RECORD_REQUEST_CODE = 42
        private const val LOG_TAG = "ScreenRecordManager"
        private const val DEFAULT_FRAME_RATE = 24
    }
}