package com.xdd.good.dad

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.xdd.good.dad.screencap.ScreenCaptureService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "good_dad/screen_capture"
    private val bridgeChannelName = "good_dad/island_bridge"
    // flutter_overlay_window 缓存的 overlay 引擎 tag（见插件 OverlayConstants）。
    private val overlayEngineTag = "myCachedEngine"
    private var pendingProjectionResult: MethodChannel.Result? = null
    private val reqProjection = 0xCA9 // capture consent request code

    // main 引擎侧的桥通道：native 收到 overlay 的请求后 invoke 到这里 → main 的 Dart。
    private var mainBridge: MethodChannel? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 灵动岛 overlay→main 桥：
        // overlay 引擎用 MethodChannel 直连 native（本类），native 再 invoke 到 main 引擎。
        // 绕开 flutter_overlay_window 的 shareData——它的 overlay→main 转发因静态
        // messenger 被 overlay 引擎 attach 覆盖而回环到 overlay 自己，main 永远收不到。
        mainBridge = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, bridgeChannelName)
        registerOverlayBridge()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // 弹系统录屏授权框；授权后启动前台服务持有 projection。
                    "requestProjection" -> {
                        if (ScreenCaptureService.instance != null) {
                            result.success(true)
                            return@setMethodCallHandler
                        }
                        pendingProjectionResult = result
                        val mpm = getSystemService(MEDIA_PROJECTION_SERVICE)
                                as MediaProjectionManager
                        startActivityForResult(
                            mpm.createScreenCaptureIntent(), reqProjection
                        )
                    }

                    // 是否已持有可用的 projection。
                    "isProjectionActive" -> {
                        result.success(ScreenCaptureService.instance != null)
                    }

                    // 抓一帧 → JPEG bytes。
                    "captureOnce" -> {
                        val quality = (call.argument<Int>("quality")) ?: 80
                        val svc = ScreenCaptureService.instance
                        if (svc == null) {
                            result.error("NO_PROJECTION", "录屏未授权或服务未启动", null)
                        } else {
                            svc.captureFrame(quality) { bytes ->
                                runOnUiThread {
                                    if (bytes == null) {
                                        result.error("CAPTURE_FAILED", "截屏失败", null)
                                    } else {
                                        result.success(bytes)
                                    }
                                }
                            }
                        }
                    }

                    // 停止截屏服务，释放 projection。
                    "stop" -> {
                        stopService(Intent(this, ScreenCaptureService::class.java))
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    /**
     * 在 overlay 引擎上挂一个 [bridgeChannelName] 的 handler：overlay 的 Dart 调
     * invokeMethod('requestCapture'/'dismiss') → 这里收到 → 转 invoke 到 main 引擎，
     * 由 main 的 Dart（IslandController）去截屏/关岛。
     *
     * overlay 引擎由 flutter_overlay_window 在 onAttachedToActivity 里异步创建，
     * configureFlutterEngine 时可能还没好，所以拿不到就 250ms 后重试。
     */
    private fun registerOverlayBridge(attempt: Int = 0) {
        val overlayEngine = FlutterEngineCache.getInstance().get(overlayEngineTag)
        if (overlayEngine == null) {
            if (attempt < 40) { // 最多重试 ~10s
                mainHandler.postDelayed({ registerOverlayBridge(attempt + 1) }, 250)
            }
            return
        }
        MethodChannel(overlayEngine.dartExecutor.binaryMessenger, bridgeChannelName)
            .setMethodCallHandler { call, result ->
                // 转发到 main 引擎的 Dart 侧（带上参数，如收藏单词的 it/zh/note）。invoke 必须在主线程。
                val args = call.arguments
                mainHandler.post { mainBridge?.invokeMethod(call.method, args) }
                result.success(true)
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == reqProjection) {
            val res = pendingProjectionResult
            pendingProjectionResult = null
            if (resultCode == Activity.RESULT_OK && data != null) {
                val svc = Intent(this, ScreenCaptureService::class.java).apply {
                    putExtra(ScreenCaptureService.EXTRA_RESULT_CODE, resultCode)
                    putExtra(ScreenCaptureService.EXTRA_RESULT_DATA, data)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(svc)
                } else {
                    startService(svc)
                }
                res?.success(true)
            } else {
                res?.success(false)
            }
        }
    }
}
