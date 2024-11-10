package dev.snaply.flutter_android.screen_video

import android.util.DisplayMetrics
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.assertEquals
import dev.snaply.flutter_android.mockLogger

class VideoSizeUtilsTest {

    @Test
    fun `test scaling for 4K screen (Samsung S21 Ultra)`() {
        val metrics = DisplayMetrics().apply {
            widthPixels = 1440
            heightPixels = 3200  // 20:9 aspect ratio
        }
        
        val size = VideoSizeUtils.getVideoSize(metrics)
        assertEquals(576, size.width)   // 1440 * 0.4
        assertEquals(1280, size.height) // 3200 * 0.4
    }

    @Test
    fun `test scaling for QHD screen (Pixel 6 Pro)`() {
        val metrics = DisplayMetrics().apply {
            widthPixels = 1440
            heightPixels = 3120  // 19.5:9 aspect ratio
        }
        
        val size = VideoSizeUtils.getVideoSize(metrics)
        assertEquals(576, size.width)   // 1440 * 0.4
        assertEquals(1248, size.height) // 3120 * 0.4
    }

    @Test
    fun `test scaling for FHD+ screen (iPhone 14 Pro)`() {
        val metrics = DisplayMetrics().apply {
            widthPixels = 1179
            heightPixels = 2556  // 19.5:9 aspect ratio
        }
        
        val size = VideoSizeUtils.getVideoSize(metrics)
        assertEquals(471, size.width)   // 1179 * 0.4
        assertEquals(1022, size.height) // 2556 * 0.4
    }

    @Test
    fun `test scaling for FHD screen (mid-range phones)`() {
        val metrics = DisplayMetrics().apply {
            widthPixels = 1080
            heightPixels = 2400  // 20:9 aspect ratio
        }
        
        val size = VideoSizeUtils.getVideoSize(metrics)
        assertEquals(540, size.width)   // 1080 * 0.5
        assertEquals(1200, size.height) // 2400 * 0.5
    }

    @Test
    fun `test scaling for HD screen (budget phones)`() {
        val metrics = DisplayMetrics().apply {
            widthPixels = 720
            heightPixels = 1600  // 20:9 aspect ratio
        }
        
        val size = VideoSizeUtils.getVideoSize(metrics)
        assertEquals(360, size.width)   // 720 * 0.5
        assertEquals(800, size.height)  // 1600 * 0.5
    }

    @Test
    fun `test invalid dimensions return default size`() {
        val metrics = DisplayMetrics().apply {
            widthPixels = -1
            heightPixels = 0
        }
        
        val size = VideoSizeUtils.getVideoSize(metrics)
        assertEquals(VideoSizeUtils.DEFAULT_SIZE.width, size.width)
        assertEquals(VideoSizeUtils.DEFAULT_SIZE.height, size.height)
    }

    @Test
    fun `test typical phone resolution (Samsung A series)`() {
        val metrics = DisplayMetrics().apply {
            widthPixels = 1080
            heightPixels = 2340  // 19.5:9 aspect ratio
        }
        
        val size = VideoSizeUtils.getVideoSize(metrics)
        assertEquals(540, size.width)   // 1080 * 0.5
        assertEquals(1170, size.height) // 2340 * 0.5
    }
} 