import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void _tlog(String msg) => debugPrint('[MimoTts] $msg');

/// xiaomimimo TTS v2.5 client。
///
/// 文档：https://platform.xiaomimimo.com/docs/zh-CN/usage-guide/speech-synthesis-v2.5
///
/// **NOTE: 请求体字段名（model/voice/input/speed/response_format）** 是按主流 TTS API
/// 常见形状的占位实现；接入时翻一下官方文档把字段对齐到实际名称即可。所有改动应该
/// 集中在 [synthesize] 方法体里，不要外溢到调用方。
///
/// baseURL / apiKey 复用 LLM 配置（视觉模型即多模态模型，跟 TTS 同一家厂商）。
class MimoTtsClient {
  final String baseUrl;
  final String apiKey;
  final String voiceId;
  final double speed;

  final Dio _dio;

  /// 默认接口路径。如果文档显示是别的（如 /tts/v2.5/synthesis），改这里。
  static const _defaultPath = '/v1/audio/speech';

  MimoTtsClient({
    required this.baseUrl,
    required this.apiKey,
    required this.voiceId,
    this.speed = 1.0,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 30),
            ));

  bool get isReady =>
      baseUrl.isNotEmpty && apiKey.isNotEmpty && voiceId.isNotEmpty;

  /// 合成语音，返回 MP3 字节流。
  Future<Uint8List> synthesize(
    String text, {
    String? overrideVoiceId,
    double? overrideSpeed,
  }) async {
    if (!isReady) {
      throw const MimoTtsException('TTS 配置不完整 (baseURL / apiKey / 声音 id)');
    }
    if (text.trim().isEmpty) return Uint8List(0);

    final body = <String, dynamic>{
      'model': 'speech-2.5',
      'voice': overrideVoiceId ?? voiceId,
      'input': text,
      'speed': overrideSpeed ?? speed,
      'response_format': 'mp3',
    };

    final url = _resolveUrl();
    _tlog('POST $url voice=${body['voice']} text="${_truncate(text, 60)}"');
    try {
      final resp = await _dio.post<List<int>>(
        url,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          responseType: ResponseType.bytes,
        ),
      );
      _tlog('HTTP ${resp.statusCode}, ${resp.data?.length ?? 0}B');
      final bytes = resp.data;
      if (bytes == null || bytes.isEmpty) {
        throw const MimoTtsException('TTS 返回空音频');
      }
      if (_looksLikeJson(bytes)) {
        return _extractAudioFromJson(bytes);
      }
      return Uint8List.fromList(bytes);
    } on DioException catch (e) {
      _tlog('DioException: code=${e.response?.statusCode} body=${_truncate(e.response?.data?.toString() ?? e.message ?? "?", 400)}');
      throw MimoTtsException(_formatDioError(e),
          statusCode: e.response?.statusCode, cause: e);
    }
  }

  String _resolveUrl() {
    var base = baseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.endsWith('/v1')) {
      base = base.substring(0, base.length - 3);
    }
    return '$base$_defaultPath';
  }

  bool _looksLikeJson(List<int> bytes) {
    if (bytes.isEmpty) return false;
    final first = bytes.first;
    return first == 0x7B /* { */ || first == 0x5B /* [ */;
  }

  Uint8List _extractAudioFromJson(List<int> bytes) {
    try {
      final text = utf8.decode(bytes);
      final json = jsonDecode(text);
      if (json is Map) {
        final candidates = [
          json['audio'],
          json['data'],
          (json['data'] is Map) ? json['data']['audio'] : null,
        ];
        for (final c in candidates) {
          if (c is String && c.isNotEmpty) {
            return base64Decode(c);
          }
        }
      }
      throw MimoTtsException('TTS 返回 JSON 但未识别音频字段：${_truncate(text, 200)}');
    } catch (e) {
      if (e is MimoTtsException) rethrow;
      throw MimoTtsException('TTS 响应解析失败: $e');
    }
  }

  String _formatDioError(DioException e) {
    final code = e.response?.statusCode;
    final body = e.response?.data;
    String detail;
    try {
      if (body is List<int>) {
        detail = utf8.decode(body, allowMalformed: true);
      } else if (body is String) {
        detail = body;
      } else if (body == null) {
        detail = '';
      } else {
        detail = jsonEncode(body);
      }
    } catch (_) {
      detail = body.toString();
    }
    detail = _truncate(detail, 240);
    return [
      if (code != null) '$code',
      if (detail.isNotEmpty) detail,
      if (detail.isEmpty && (e.message ?? '').isNotEmpty) e.message,
    ].whereType<String>().join(' · ');
  }

  String _truncate(String s, int n) =>
      s.length <= n ? s : '${s.substring(0, n)}…';
}

class MimoTtsException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const MimoTtsException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'MimoTtsException: $message';
}
