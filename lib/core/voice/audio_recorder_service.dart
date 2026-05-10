import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'voice_types.dart';

/// 录音服务。封装 `record` 包：
/// - 录 **WAV PCM 16-bit**（uncompressed）—— 各平台都稳，多模态 LLM 大多都吃
/// - 单声道 16kHz —— 体积尚可，对人声识别足够
/// - 文件落到临时目录，stop() 时读出字节再删
class AudioRecorderService {
  final AudioRecorder _recorder;
  String? _currentPath;

  AudioRecorderService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  Future<void> start() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    final dir = await getTemporaryDirectory();
    final filename =
        'voice_${DateTime.now().millisecondsSinceEpoch}.wav';
    _currentPath = p.join(dir.path, filename);
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 256000,
      ),
      path: _currentPath!,
    );
  }

  /// 停止录音并返回字节。
  Future<RecordedAudio?> stop() async {
    final path = await _recorder.stop();
    final used = path ?? _currentPath;
    _currentPath = null;
    if (used == null) return null;
    final file = File(used);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    try {
      await file.delete();
    } catch (_) {}
    if (bytes.isEmpty) return null;
    return RecordedAudio(
      bytes: Uint8List.fromList(bytes),
      mimeType: 'audio/wav',
    );
  }

  Future<void> cancel() async {
    final path = _currentPath;
    _currentPath = null;
    try {
      await _recorder.cancel();
    } catch (_) {
      try {
        await _recorder.stop();
      } catch (_) {}
    }
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  Future<bool> isRecording() => _recorder.isRecording();

  /// 实时音量（normalized 0-1）。dBFS：silence≈-60, voice≈-30~-10, loud≈0。
  /// 仅在录音时有数据；非录音时流上没事件，UI 应自己回到 0。
  Stream<double> amplitudeStream({Duration interval = const Duration(milliseconds: 80)}) {
    return _recorder.onAmplitudeChanged(interval).map((a) {
      final dbfs = a.current.isFinite ? a.current : -60.0;
      final norm = ((dbfs + 60) / 60).clamp(0.0, 1.0);
      return norm;
    });
  }

  Future<void> dispose() => _recorder.dispose();
}
