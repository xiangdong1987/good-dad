package com.xdd.good.dad.screencap

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.DisplayMetrics
import android.view.WindowManager
import java.io.ByteArrayOutputStream

/**
 * 驾照灵动岛的截屏前台服务。
 *
 * 生命周期：开启灵动岛时 [start] 一次（用户授权录屏后），持有 MediaProjection 整场复用；
 * 每次点小岛调 [captureFrame] 抓一帧 → JPEG bytes；关灵动岛时停服务释放 projection。
 *
 * Android 10+ 必须前台服务，14+ 必须 foregroundServiceType=mediaProjection（已在 manifest 声明）。
 */
class ScreenCaptureService : Service() {

    companion object {
        @Volatile
        var instance: ScreenCaptureService? = null

        const val EXTRA_RESULT_CODE = "result_code"
        const val EXTRA_RESULT_DATA = "result_data"

        private const val CHANNEL_ID = "license_island_capture"
        private const val NOTIF_ID = 4711
    }

    private var projection: MediaProjection? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundNotification()

        val resultCode = intent?.getIntExtra(EXTRA_RESULT_CODE, 0) ?: 0
        val resultData = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent?.getParcelableExtra(EXTRA_RESULT_DATA, Intent::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent?.getParcelableExtra(EXTRA_RESULT_DATA)
        }

        if (resultCode != 0 && resultData != null) {
            val mpm = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            projection = mpm.getMediaProjection(resultCode, resultData)?.also { mp ->
                // Android 14 要求注册 callback，否则 getMediaProjection 之后立刻抛异常。
                mp.registerCallback(object : MediaProjection.Callback() {
                    override fun onStop() {
                        projection = null
                    }
                }, mainHandler)
            }
            instance = this
        }
        return START_NOT_STICKY
    }

    /** 抓一帧当前屏幕，回调 JPEG 字节（失败回 null）。一次性 VirtualDisplay，用完即释放。 */
    fun captureFrame(quality: Int, onResult: (ByteArray?) -> Unit) {
        val mp = projection
        if (mp == null) {
            onResult(null)
            return
        }

        val metrics = DisplayMetrics()
        val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        @Suppress("DEPRECATION")
        wm.defaultDisplay.getRealMetrics(metrics)
        val width = metrics.widthPixels
        val height = metrics.heightPixels
        val density = metrics.densityDpi

        val reader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
        var virtualDisplay: VirtualDisplay? = null
        var done = false

        fun cleanup() {
            try { virtualDisplay?.release() } catch (_: Throwable) {}
            try { reader.close() } catch (_: Throwable) {}
        }

        reader.setOnImageAvailableListener({ r ->
            if (done) return@setOnImageAvailableListener
            val image = try { r.acquireLatestImage() } catch (_: Throwable) { null }
            if (image == null) return@setOnImageAvailableListener
            done = true
            try {
                val plane = image.planes[0]
                val buffer = plane.buffer
                val pixelStride = plane.pixelStride
                val rowStride = plane.rowStride
                val rowPadding = rowStride - pixelStride * width

                val bitmap = Bitmap.createBitmap(
                    width + rowPadding / pixelStride,
                    height,
                    Bitmap.Config.ARGB_8888
                )
                bitmap.copyPixelsFromBuffer(buffer)
                val cropped = Bitmap.createBitmap(bitmap, 0, 0, width, height)

                val out = ByteArrayOutputStream()
                cropped.compress(Bitmap.CompressFormat.JPEG, quality, out)
                bitmap.recycle()
                cropped.recycle()
                mainHandler.post { onResult(out.toByteArray()) }
            } catch (t: Throwable) {
                mainHandler.post { onResult(null) }
            } finally {
                image.close()
                cleanup()
            }
        }, mainHandler)

        try {
            virtualDisplay = mp.createVirtualDisplay(
                "license_island_capture",
                width, height, density,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                reader.surface, null, mainHandler
            )
        } catch (t: Throwable) {
            cleanup()
            onResult(null)
            return
        }

        // 兜底：1.5s 没拿到帧就放弃，避免回调悬空。
        mainHandler.postDelayed({
            if (!done) {
                done = true
                cleanup()
                onResult(null)
            }
        }, 1500)
    }

    private fun startForegroundNotification() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(
                CHANNEL_ID,
                "驾照灵动岛",
                NotificationManager.IMPORTANCE_LOW
            ).apply { setShowBadge(false) }
            nm.createNotificationChannel(ch)
        }
        val notif: Notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("驾照小岛待命中")
                .setContentText("学车刷题时点一下小岛，我帮你看题")
                .setSmallIcon(android.R.drawable.ic_menu_camera)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("驾照小岛待命中")
                .setContentText("学车刷题时点一下小岛，我帮你看题")
                .setSmallIcon(android.R.drawable.ic_menu_camera)
                .setOngoing(true)
                .build()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIF_ID,
                notif,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
            )
        } else {
            startForeground(NOTIF_ID, notif)
        }
    }

    override fun onDestroy() {
        try { projection?.stop() } catch (_: Throwable) {}
        projection = null
        instance = null
        super.onDestroy()
    }
}
