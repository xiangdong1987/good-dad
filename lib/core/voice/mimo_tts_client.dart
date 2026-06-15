import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../llm_log/llm_log_recorder.dart';
import '../llm_log/llm_log_repository.dart';

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

  /// HTTP 路径（拼在 baseUrl 后），从 [VoiceConfig.ttsPath] 来；可在设置页改。
  /// 默认 `/v1/audio/speech`（OpenAI 兼容），404 时大概率是这里要换成厂商正确路径。
  final String path;

  final LlmLogRepository? logger;

  final Dio _dio;

  MimoTtsClient({
    required this.baseUrl,
    required this.apiKey,
    required this.voiceId,
    required this.path,
    this.speed = 1.0,
    this.logger,
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

    final scope = LlmLogScope.start(
      logger,
      channel: 'mimo-tts',
      model: body['model']?.toString() ?? 'speech-2.5',
      requestSummary: 'voice=${body['voice']} speed=${body['speed']} '
          'text="${_truncate(text, 100)}"',
      rawRequest: jsonEncode(body),
    );

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
        scope.error(
          message: 'TTS 返回空音频',
          statusCode: resp.statusCode,
        );
        throw const MimoTtsException('TTS 返回空音频');
      }
      Uint8List finalBytes;
      if (_looksLikeJson(bytes)) {
        finalBytes = _extractAudioFromJson(bytes);
      } else {
        finalBytes = Uint8List.fromList(bytes);
      }
      scope.success(
        responseSummary: '${finalBytes.length}B audio',
        statusCode: resp.statusCode,
      );
      return finalBytes;
    } on DioException catch (e) {
      _tlog('DioException: code=${e.response?.statusCode} body=${_truncate(e.response?.data?.toString() ?? e.message ?? "?", 400)}');
      scope.error(
        message: _formatDioError(e),
        statusCode: e.response?.statusCode,
        rawResponse: e.response?.data?.toString(),
      );
      throw MimoTtsException(_formatDioError(e),
          statusCode: e.response?.statusCode, cause: e);
    } on MimoTtsException catch (e) {
      scope.error(message: e.message, statusCode: e.statusCode);
      rethrow;
    } catch (e) {
      scope.error(message: e.toString());
      rethrow;
    }
  }

  String _resolveUrl() {
    var base = baseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    var p = path.trim();
    if (!p.startsWith('/')) p = '/$p';
    // 自动去重：path 如果以 /v1 开头但 base 也以 /v1 结尾，砍 base 的 /v1
    if (p.startsWith('/v1') && base.endsWith('/v1')) {
      base = base.substring(0, base.length - 3);
    }
    return '$base$p';
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

/// 一组 mimo / OpenAI 兼容 / Azure 等 TTS 服务常见路径，按出现频率排序。
/// 探测时按这个顺序试，遇到非 404 就停（200 = 成功；401/403 = 路径对了但 auth/voice id 问题）。
const List<String> kTtsCommonPaths = [
  '/v1/audio/speech', // OpenAI
  '/v1/tts',
  '/v1/audio/tts',
  '/v1/text-to-speech',
  '/v1/speech',
  '/v1/speech/synthesize',
  '/v2.5/tts',
  '/v2.5/audio/speech',
  '/openapi/tts',
  '/openapi/v1/tts',
  '/api/v1/tts',
  '/tts/v2.5',
  '/tts/v1/synthesize',
];

/// 探测 TTS endpoint：用最小请求体打每个候选路径，遇到 **非 404** 就返回该路径。
/// 401/403/400 都算"路径找对了，是别的问题"——通常意味着这就是正确路径。
///
/// 返回 null 表示所有候选都 404（或全部失败）；调用方应提示用户去文档手动填。
class MimoTtsProber {
  final String baseUrl;
  final String apiKey;
  final String voiceId;
  final Dio _dio;

  MimoTtsProber({
    required this.baseUrl,
    required this.apiKey,
    required this.voiceId,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 5),
              validateStatus: (_) => true, // 自己处理状态码
            ));

  Future<TtsProbeResult> probe({List<String>? paths}) async {
    final list = paths ?? kTtsCommonPaths;
    final attempts = <TtsProbeAttempt>[];
    for (final p in list) {
      final url = _resolve(p);
      try {
        final resp = await _dio.post<dynamic>(
          url,
          data: {
            'model': 'speech-2.5',
            'voice': voiceId.isEmpty ? 'default' : voiceId,
            'input': 'ping',
            'response_format': 'mp3',
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
          ),
        );
        final code = resp.statusCode ?? -1;
        attempts.add(TtsProbeAttempt(path: p, statusCode: code));
        if (code != 404) {
          // 找到了——404 是 path 不存在；其它都视为 path 对路
          return TtsProbeResult(workingPath: p, attempts: attempts);
        }
      } catch (e) {
        attempts.add(TtsProbeAttempt(path: p, statusCode: -1, error: '$e'));
      }
    }
    return TtsProbeResult(workingPath: null, attempts: attempts);
  }

  String _resolve(String p) {
    var base = baseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    var path = p;
    if (!path.startsWith('/')) path = '/$path';
    if (path.startsWith('/v1') && base.endsWith('/v1')) {
      base = base.substring(0, base.length - 3);
    }
    return '$base$path';
  }
}

class TtsProbeResult {
  final String? workingPath;
  final List<TtsProbeAttempt> attempts;
  const TtsProbeResult({required this.workingPath, required this.attempts});
}

class TtsProbeAttempt {
  final String path;
  final int statusCode; // -1 表示连接错误
  final String? error;
  const TtsProbeAttempt({
    required this.path,
    required this.statusCode,
    this.error,
  });
}
