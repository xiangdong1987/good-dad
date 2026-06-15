import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../llm_log/llm_log_recorder.dart';
import '../llm_log/llm_log_repository.dart';
import 'voice_types.dart';

void _alog(String msg) => debugPrint('[MimoAgent] $msg');

/// xiaomimimo 多模态音频理解 client。
///
/// 文档：https://platform.xiaomimimo.com/docs/zh-CN/usage-guide/multimodal-understanding/audio-understanding
///
/// 直接把用户录音 + system prompt + 工具定义一起发给模型，让模型「听 + 理解 + 决策」。
///
/// 默认**只要文字回复**，TTS 走独立的 `/v1/audio/speech` 路径。
/// 想用「文字 + 音频一并返回」的 modalities 协议，把 [useInlineAudio] 设为 true
/// （但前提是 mimo 真支持 OpenAI gpt-4o-audio 那套，否则返回会变空）。
///
/// baseURL / apiKey / model 复用 LLM 配置（视觉模型 = 多模态模型）。
class MimoAgentClient {
  final String baseUrl;
  final String apiKey;
  final String model;

  /// 模型直接合成语音用的声音 id；只在 [useInlineAudio] 为 true 时才用。
  final String? voiceId;

  /// 是否启用「文字 + 音频一起返回」的 modalities 协议（实验性）。
  /// 默认 false——mimo 是否兼容 OpenAI gpt-4o-audio 协议未知，开了可能导致 content 为空。
  final bool useInlineAudio;

  /// 可选日志仓库；非 null 时每次调用写一条日志到设置页可见。
  final LlmLogRepository? logger;

  final Dio _dio;

  static const _defaultPath = '/chat/completions';

  MimoAgentClient({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.voiceId,
    this.useInlineAudio = false,
    this.logger,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 60),
            ));

  bool get isReady =>
      baseUrl.isNotEmpty && apiKey.isNotEmpty && model.isNotEmpty;

  bool get audioOutputEnabled =>
      useInlineAudio && (voiceId ?? '').isNotEmpty;

  /// 把音频 + 上下文 + 工具集发给模型，期望返回 JSON intent。
  Future<AgentResponse> understand({
    required RecordedAudio audio,
    required String systemPrompt,
    PageContext? pageContext,
  }) async {
    if (!isReady) {
      throw const MimoAgentException(
          '语音 agent 配置不完整 (baseURL / apiKey / model)');
    }

    final body = _buildRequestBody(
      audio: audio,
      systemPrompt: systemPrompt,
      pageContext: pageContext,
    );

    final url = _resolveUrl();
    _alog('POST $url model=$model audio=${audio.bytes.length}B mime=${audio.mimeType}');

    final scope = LlmLogScope.start(
      logger,
      channel: 'mimo-agent',
      model: model,
      requestSummary: 'audio ${audio.bytes.length}B + system ${systemPrompt.length}c'
          '${pageContext == null ? '' : ' + page=${pageContext.kind}'}',
      rawRequest: _safeRawRequest(body),
    );

    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        url,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
      );
      _alog('HTTP ${resp.statusCode}, payload keys=${resp.data?.keys.toList()}');
      final parsed = _parseResponse(resp.data);
      scope.success(
        responseSummary: 'tool=${parsed.toolName ?? "-"} '
            'speak="${_truncate(parsed.speakText, 100)}"',
        statusCode: resp.statusCode,
        rawResponse: resp.data == null ? null : jsonEncode(resp.data),
      );
      return parsed;
    } on DioException catch (e) {
      _alog('DioException: code=${e.response?.statusCode} body=${_truncate(e.response?.data?.toString() ?? e.message ?? "?", 400)}');
      scope.error(
        message: _formatDioError(e),
        statusCode: e.response?.statusCode,
        rawResponse: e.response?.data?.toString(),
      );
      throw MimoAgentException(_formatDioError(e),
          statusCode: e.response?.statusCode, cause: e);
    } catch (e) {
      scope.error(message: e.toString());
      rethrow;
    }
  }

  /// 把 audio bytes 从 body 里剥掉再 jsonEncode —— 不然日志会塞 base64 巨长。
  String _safeRawRequest(Map<String, dynamic> body) {
    final clone = Map<String, dynamic>.from(body);
    try {
      final messages = clone['messages'];
      if (messages is List) {
        clone['messages'] = messages.map((m) {
          if (m is! Map) return m;
          final mm = Map<String, dynamic>.from(m);
          final content = mm['content'];
          if (content is List) {
            mm['content'] = content.map((part) {
              if (part is Map && part['type'] == 'input_audio') {
                final pp = Map<String, dynamic>.from(part);
                final audio = pp['input_audio'];
                if (audio is Map) {
                  final aa = Map<String, dynamic>.from(audio);
                  if (aa['data'] is String) {
                    aa['data'] = '<${(aa['data'] as String).length}B base64 audio>';
                  }
                  pp['input_audio'] = aa;
                }
                return pp;
              }
              return part;
            }).toList();
          }
          return mm;
        }).toList();
      }
      return jsonEncode(clone);
    } catch (_) {
      return jsonEncode({'_': 'raw request stripped'});
    }
  }

  /// 构造请求体。**官方文档落实后，请求体形状的调整集中改这里。**
  Map<String, dynamic> _buildRequestBody({
    required RecordedAudio audio,
    required String systemPrompt,
    PageContext? pageContext,
  }) {
    final fullSystem = _composeSystem(systemPrompt, pageContext);
    final audioFormat = _audioFormatFromMime(audio.mimeType);
    final audioBase64 = base64Encode(audio.bytes);

    final body = <String, dynamic>{
      'model': model,
      'stream': false,
      'temperature': 0.2,
      'messages': [
        {'role': 'system', 'content': fullSystem},
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_audio',
              'input_audio': {
                'data': audioBase64,
                'format': audioFormat,
              },
            },
          ],
        },
      ],
    };

    if (audioOutputEnabled) {
      // 模型直接吐音频回来（OpenAI gpt-4o-audio 同款协议）。
      body['modalities'] = ['text', 'audio'];
      body['audio'] = {
        'voice': voiceId,
        'format': 'mp3',
      };
    } else {
      // 没配 voiceId — 只要文字，强制 JSON 输出方便解析。
      body['response_format'] = {'type': 'json_object'};
    }

    return body;
  }

  String _composeSystem(String base, PageContext? ctx) {
    if (ctx == null) return base;
    final ctxJson = jsonEncode({'kind': ctx.kind, 'payload': ctx.payload});
    return '$base\n\n当前页面上下文：$ctxJson';
  }

  String _audioFormatFromMime(String mime) {
    final m = mime.toLowerCase();
    if (m.contains('mpeg') || m.contains('mp3')) return 'mp3';
    if (m.contains('wav')) return 'wav';
    if (m.contains('aac') || m.contains('m4a')) return 'aac';
    if (m.contains('opus')) return 'opus';
    if (m.contains('flac')) return 'flac';
    return 'mp3';
  }

  AgentResponse _parseResponse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const MimoAgentException('agent 返回空响应');
    }
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw MimoAgentException(
          'agent 响应无 choices: ${_truncate(jsonEncode(data), 240)}');
    }
    final msg = choices.first['message'];
    if (msg is! Map) {
      throw MimoAgentException(
          'agent 响应无 message: ${_truncate(jsonEncode(data), 240)}');
    }

    // 1) 抽音频字节（如果有）。
    Uint8List? audioBytes;
    final audioObj = msg['audio'];
    if (audioObj is Map) {
      final dataStr = audioObj['data'];
      if (dataStr is String && dataStr.isNotEmpty) {
        try {
          audioBytes = base64Decode(dataStr);
        } catch (_) {}
      }
    }

    // 2) 抽文字内容。
    String content = '';
    final c = msg['content'];
    if (c is String) {
      content = c;
    } else if (audioObj is Map && audioObj['transcript'] is String) {
      content = audioObj['transcript'] as String;
    }

    // 3) 解析 JSON intent。
    final parsed = content.isEmpty ? null : _extractJson(content);
    if (parsed == null) {
      // 模型没按 JSON 输出——把整段当作直接回答（chat_fallback）。
      return AgentResponse(
        speakText: content.trim(),
        audioBytes: audioBytes,
        raw: data,
      );
    }
    final action = parsed['action'];
    final args = parsed['args'];
    final speak = parsed['speak'];
    final transcript = parsed['transcript'];
    return AgentResponse(
      toolName: action is String && action.isNotEmpty ? action : null,
      args: args is Map<String, dynamic>
          ? args
          : (args is Map ? Map<String, dynamic>.from(args) : const {}),
      speakText: speak is String && speak.isNotEmpty
          ? speak
          : content.trim(),
      transcript: transcript is String ? transcript : null,
      audioBytes: audioBytes,
      raw: data,
    );
  }

  /// 宽容 JSON 提取：复用项目里 italian_license_prompt 的「找首尾大括号」思路。
  Map<String, dynamic>? _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    final candidate = text.substring(start, end + 1);
    try {
      final json = jsonDecode(candidate);
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return null;
  }

  String _resolveUrl() {
    var base = baseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (!base.endsWith('/v1') && !base.contains('/v')) {
      base = '$base/v1';
    }
    return '$base$_defaultPath';
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

class MimoAgentException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const MimoAgentException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'MimoAgentException: $message';
}
