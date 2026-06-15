import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 系统 TTS 兜底。
///
/// xiaomimimo TTS 没配 / 调用失败时用这个，保证用户始终能听到回复。
/// 默认中文，跟着系统的 TTS 引擎走（小米/华为/Google）。
class SystemTtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.5); // flutter_tts 的 0.5 在 Android 是接近正常语速
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _initialized = true;
    } catch (e) {
      debugPrint('[SystemTts] init error: $e');
    }
  }

  /// 朗读一段中文文本，等播放结束。
  Future<void> speak(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await _ensureInit();
    try {
      await _tts.stop();
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(t);
    } catch (e) {
      debugPrint('[SystemTts] speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
