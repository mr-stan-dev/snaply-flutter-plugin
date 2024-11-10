package dev.snaply.flutter_android.screen_video

import android.app.Activity
import android.view.Display
import android.view.WindowManager
import android.util.DisplayMetrics
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.assertEquals
import dev.snaply.flutter_android.mockLogger

class ScreenMetricsUtilsTest {
    @BeforeEach
    fun setup() {
        mockLogger()
    }

    @Test
    fun `test getMetrics returns valid metrics`() {
        val activity = mockk<Activity>()
        val windowManager = mockk<WindowManager>()
        val display = mockk<Display>()
        val metricsSlot = slot<DisplayMetrics>()

        every { activity.windowManager } returns windowManager
        every { windowManager.defaultDisplay } returns display
        every { display.getMetrics(capture(metricsSlot)) } answers {
            metricsSlot.captured.apply {
                widthPixels = 1080
                heightPixels = 1920
                density = 2.0f
                densityDpi = 320
            }
        }

        val metrics = ScreenMetricsUtils.getMetrics(activity)
        assertEquals(1080, metrics.widthPixels)
        assertEquals(1920, metrics.heightPixels)
        assertEquals(2.0f, metrics.density)
        assertEquals(320, metrics.densityDpi)
    }

    @Test
    fun `test getMetrics returns default metrics when display is null`() {
        val activity = mockk<Activity>()
        val windowManager = mockk<WindowManager>()

        every { activity.windowManager } returns windowManager
        every { windowManager.defaultDisplay } returns null

        val metrics = ScreenMetricsUtils.getMetrics(activity)
        assertEquals(1080, metrics.widthPixels)
        assertEquals(1920, metrics.heightPixels)
        assertEquals(1.0f, metrics.density)
        assertEquals(DisplayMetrics.DENSITY_DEFAULT, metrics.densityDpi)
    }

    @Test
    fun `test getMetrics returns default metrics when dimensions are invalid`() {
        val activity = mockk<Activity>()
        val windowManager = mockk<WindowManager>()
        val display = mockk<Display>()
        val metricsSlot = slot<DisplayMetrics>()

        every { activity.windowManager } returns windowManager
        every { windowManager.defaultDisplay } returns display
        every { display.getMetrics(capture(metricsSlot)) } answers {
            metricsSlot.captured.apply {
                widthPixels = 0
                heightPixels = -1
            }
        }

        val metrics = ScreenMetricsUtils.getMetrics(activity)
        assertEquals(1080, metrics.widthPixels)
        assertEquals(1920, metrics.heightPixels)
    }
}
