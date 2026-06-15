import 'dart:async';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

/// 把 TTS 返回的字节流播放出来。封装 just_audio 的 BytesAudioSource。
class AudioPlayerService {
  final AudioPlayer _player;

  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  /// 播放给定字节，等待播放完成或被打断。
  ///
  /// MIME 默认 'audio/mpeg'。可以重复调用——会先 stop 再播。
  Future<void> playBytes(
    Uint8List bytes, {
    String contentType = 'audio/mpeg',
  }) async {
    if (bytes.isEmpty) return;
    await _player.stop();
    await _player.setAudioSource(_BytesAudioSource(bytes, contentType));
    await _player.play();
    await _player.processingStateStream
        .firstWhere((s) => s == ProcessingState.completed);
  }

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();

  bool get isPlaying => _player.playing;
}

class _BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;
  final String _contentType;

  _BytesAudioSource(this._bytes, this._contentType);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final s = start ?? 0;
    final e = end ?? _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: e - s,
      offset: s,
      stream: Stream.value(_bytes.sublist(s, e)),
      contentType: _contentType,
    );
  }
}
