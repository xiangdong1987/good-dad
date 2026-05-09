import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'voice_types.dart';

void _alog(String msg) => debugPrint('[MimoAgent] $msg');

/// xiaomimimo 多模态音频理解 client。
///
/// 文档：https://platform.xiaomimimo.com/docs/zh-CN/usage-guide/multimodal-understanding/audio-understanding
///
/// 直接把用户录音 + system prompt + 工具定义一起发给模型，让模型同时做：
/// 1. 「听」用户音频
/// 2. 「理解」生成 JSON 决定调用哪个工具
/// 3. 「说」直接返回音频字节（如果配了 voiceId，走 modalities: text+audio）
///
/// baseURL / apiKey / model 复用 LLM 配置（视觉模型 = 多模态模型）。
class MimoAgentClient {
  final String baseUrl;
  final String apiKey;
  final String model;

  /// 模型直接合成语音用的声音 id；为空则只返回文字（orchestrator 走兜底 TTS）。
  final String? voiceId;
  final Dio _dio;

  static const _defaultPath = '/chat/completions';

  MimoAgentClient({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.voiceId,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 60),
            ));

  bool get isReady =>
      baseUrl.isNotEmpty && apiKey.isNotEmpty && model.isNotEmpty;

  bool get audioOutputEnabled => (voiceId ?? '').isNotEmpty;

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
      return _parseResponse(resp.data);
    } on DioException catch (e) {
      _alog('DioException: code=${e.response?.statusCode} body=${_truncate(e.response?.data?.toString() ?? e.message ?? "?", 400)}');
      throw MimoAgentException(_formatDioError(e),
          statusCode: e.response?.statusCode, cause: e);
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
