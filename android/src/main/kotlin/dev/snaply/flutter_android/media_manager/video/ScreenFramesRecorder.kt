package dev.snaply.flutter_android.media_manager.video

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Surface
import dev.snaply.flutter_android.media_manager.ScreenshotResizer
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class ScreenFramesRecorder {
    companion object {
        private const val LOG_TAG = "ScreenFramesRecorder"
        private const val FRAME_DELAY_MS = 50L // 20fps
        private const val MIME_TYPE = MediaFormat.MIMETYPE_VIDEO_AVC
        private const val I_FRAME_INTERVAL = 1
        private const val BIT_RATE = 2_000_000
    }

    private var isRecording = false
    private var encoder: MediaCodec? = null
    private var muxer: MediaMuxer? = null
    private var inputSurface: Surface? = null
    private var executor: ScheduledExecutorService? = null
    private var startTime: Long = 0
    private var trackIndex = -1
    private var outputFilePath: String? = null
    private var frameCount = 0
    private val mainHandler = Handler(Looper.getMainLooper())
    private val bufferInfo = MediaCodec.BufferInfo()

    @SuppressLint("DiscouragedApi")
    fun startRecording(
        outputFilePath: String,
        bitmapProvider: () -> Bitmap
    ) {
        if (isRecording) {
            Log.d(LOG_TAG, "Already recording, stopping current recording first")
            stopRecording()
        }

        cleanup()

        try {
            val bitmap = bitmapProvider.invoke()
            Log.d(LOG_TAG, "original screen size: ${bitmap.width} to ${bitmap.height}")

            val (width, height) = ScreenshotResizer.getResized(bitmap.width, bitmap.height)
            Log.d(LOG_TAG, "scaled screen size:  $width to $height")

            this.outputFilePath = outputFilePath
            Log.d(LOG_TAG, "startRecording outputFilePath: $outputFilePath")

            setupEncoder(width, height)
            setupMuxer()

            isRecording = true
            startTime = System.currentTimeMillis()
            frameCount = 0

            executor = Executors.newSingleThreadScheduledExecutor().apply {
                scheduleAtFixedRate(
                    { captureFrame(width, height, bitmapProvider) },
                    0,
                    FRAME_DELAY_MS,
                    TimeUnit.MILLISECONDS
                )
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to start recording: ${e.message}")
            stopRecording()
        }
    }

    private fun captureFrame(width: Int, height: Int, bitmapProvider: () -> Bitmap) {
        try {
            mainHandler.post {
                try {
                    val bitmap = bitmapProvider.invoke()
                        ?: throw IllegalStateException("Bitmap provider not set")

                    // Scale bitmap to match encoder dimensions
                    val matrix = android.graphics.Matrix().apply {
                        setScale(
                            width.toFloat() / bitmap.width,
                            height.toFloat() / bitmap.height
                        )
                    }

                    val canvas = inputSurface?.lockCanvas(null)
                    canvas?.let { c ->
                        // Draw scaled bitmap
                        c.drawBitmap(bitmap, matrix, null)
                        inputSurface?.unlockCanvasAndPost(c)
                    }

                    drainEncoder(false)
                    frameCount++
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Failed to capture frame on main thread: ${e.message}")
                }
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to schedule frame capture: ${e.message}")
        }
    }

    private fun drainEncoder(endOfStream: Boolean) {
        if (endOfStream) {
            encoder?.signalEndOfInputStream()
        }

        while (true) {
            val outputBufferIndex = encoder?.dequeueOutputBuffer(bufferInfo, 0) ?: -1
            when (outputBufferIndex) {
                MediaCodec.INFO_TRY_AGAIN_LATER -> break // No output available yet
                MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    // Happens only once at the start
                    val newFormat = encoder?.outputFormat
                    Log.d(LOG_TAG, "Encoder output format changed: $newFormat")
                    trackIndex = muxer?.addTrack(newFormat!!) ?: -1
                    muxer?.start()
                }

                else -> {
                    // Valid output buffer
                    val encodedData = encoder?.getOutputBuffer(outputBufferIndex)
                    if (encodedData != null && bufferInfo.size > 0) {
                        encodedData.position(bufferInfo.offset)
                        encodedData.limit(bufferInfo.offset + bufferInfo.size)
                        muxer?.writeSampleData(trackIndex, encodedData, bufferInfo)
                        encoder?.releaseOutputBuffer(outputBufferIndex, false)
                    }
                }
            }
        }
    }

    private fun setupEncoder(width: Int, height: Int) {
        val format = MediaFormat.createVideoFormat(MIME_TYPE, width, height).apply {
            setInteger(
                MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface
            )
            setInteger(MediaFormat.KEY_BIT_RATE, BIT_RATE)
            setInteger(MediaFormat.KEY_FRAME_RATE, (1000 / FRAME_DELAY_MS).toInt())
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, I_FRAME_INTERVAL)
        }

        encoder = MediaCodec.createEncoderByType(MIME_TYPE).apply {
            configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            inputSurface = createInputSurface()
            start()
        }
    }

    private fun setupMuxer() {
        muxer = MediaMuxer(
            outputFilePath!!,
            MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4
        )
    }

    fun stopRecording(): String? {
        Log.d(LOG_TAG, "stopRecording isRecording: $isRecording")
        if (!isRecording) return null

        try {
            isRecording = false
            executor?.shutdown()
            executor?.awaitTermination(1, TimeUnit.SECONDS)

            drainEncoder(true) // Drain any remaining output

            releaseMediaResources() // Extract media resource cleanup to separate method

            Log.d(LOG_TAG, "stopRecording outputFile: $outputFilePath")
            return outputFilePath
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to stop recording: ${e.message}")
        } finally {
            cleanup()
        }
        return null
    }

    private fun releaseMediaResources() {
        try {
            if (encoder != null) {
                encoder?.stop()
                encoder?.release()
                encoder = null
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error releasing encoder: ${e.message}")
        }

        try {
            if (muxer != null) {
                muxer?.stop()
                muxer?.release()
                muxer = null
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error releasing muxer: ${e.message}")
        }

        try {
            inputSurface?.release()
            inputSurface = null
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error releasing input surface: ${e.message}")
        }
    }

    private fun cleanup() {
        try {
            isRecording = false
            trackIndex = -1
            startTime = 0
            frameCount = 0

            executor?.shutdownNow()
            executor = null

            outputFilePath = null

            // Clear any pending frame captures
            mainHandler.removeCallbacksAndMessages(null)
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error during cleanup: ${e.message}")
        }
    }
} 