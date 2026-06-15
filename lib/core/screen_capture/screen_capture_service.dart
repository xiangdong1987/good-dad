import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 对接原生 MediaProjection 截屏前台服务（com.xdd.good.dad/screencap）。
///
/// 只负责"录屏授权 + 抓一帧"，悬浮窗本身由 flutter_overlay_window 负责。
/// 仅 Android 实现；iOS 不支持跨 App 截屏，调用会抛 MissingPluginException，
/// 上层用 [isSupported] 提前挡掉。
class ScreenCaptureService {
  static const _channel = MethodChannel('good_dad/screen_capture');

  const ScreenCaptureService();

  /// 弹系统录屏授权框（整场只需授权一次，由前台服务持有 projection）。
  /// 返回 true=已可用 / 用户同意。
  Future<bool> requestProjection() async {
    final ok = await _channel.invokeMethod<bool>('requestProjection');
    return ok ?? false;
  }

  /// 是否已持有可用的 projection（服务在跑）。
  Future<bool> isProjectionActive() async {
    final ok = await _channel.invokeMethod<bool>('isProjectionActive');
    return ok ?? false;
  }

  /// 抓一帧当前整屏，返回 JPEG bytes。失败抛 [PlatformException]。
  Future<Uint8List> captureOnce({int quality = 85}) async {
    final bytes = await _channel.invokeMethod<Uint8List>(
      'captureOnce',
      {'quality': quality},
    );
    if (bytes == null) {
      throw PlatformException(code: 'CAPTURE_FAILED', message: '截屏返回空');
    }
    return bytes;
  }

  /// 停止截屏服务，释放 projection。
  Future<void> stop() async {
    await _channel.invokeMethod<void>('stop');
  }
}

final screenCaptureServiceProvider = Provider<ScreenCaptureService>(
  (ref) => const ScreenCaptureService(),
);
