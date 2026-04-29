import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/llm_config.dart';
import 'llm_client.dart';
import 'types.dart';

/// OpenAI Chat Completions compatible client.
///
/// Works with OpenAI, DeepSeek, 通义千问, 豆包 and any other vendor that
/// exposes a `/v1/chat/completions` endpoint with SSE streaming.
class OpenAICompatibleClient extends LlmClient {
  final LlmConfig config;
  final Dio _dio;

  OpenAICompatibleClient(this.config, {Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(minutes: 5),
              sendTimeout: const Duration(minutes: 2),
            ));

  String _resolveUrl() => _resolvePath('chat/completions');

  String _resolveModelsUrl() => _resolvePath('models');

  String _resolvePath(String suffix) {
    var base = config.baseUrl.trim();
    if (base.isEmpty) {
      throw const LlmException('未配置 baseURL');
    }
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.endsWith('/chat/completions')) {
      // baseUrl 已是完整聊天端点；把它降级回 /v1 再拼后缀
      base = base.substring(0, base.length - '/chat/completions'.length);
    }
    if (!base.endsWith('/v1') && !base.contains('/v')) base = '$base/v1';
    return '$base/$suffix';
  }

  Map<String, dynamic> _encodeMessage(LlmMessage m) {
    final role = switch (m.role) {
      LlmRole.system => 'system',
      LlmRole.user => 'user',
      LlmRole.assistant => 'assistant',
      LlmRole.tool => 'tool',
    };

    if (!m.hasImage) {
      return {'role': role, 'content': m.textContent};
    }

    final content = <Map<String, dynamic>>[];
    for (final p in m.parts) {
      if (p is TextPart) {
        if (p.text.isNotEmpty) {
          content.add({'type': 'text', 'text': p.text});
        }
      } else if (p is ImagePart) {
        content.add({
          'type': 'image_url',
          'image_url': {'url': p.toDataUrl()},
        });
      }
    }
    if (content.isEmpty) {
      content.add({'type': 'text', 'text': ''});
    }
    return {'role': role, 'content': content};
  }

  @override
  Stream<LlmChunk> chat(
    List<LlmMessage> messages, {
    String? model,
    double? temperature,
    bool needsVision = false,
  }) async* {
    if (!config.isComplete) {
      throw const LlmException('LLM 未配置完整 (baseURL / apiKey / model)');
    }

    final usedModel =
        model ?? (needsVision ? config.visionModel : config.chatModel);
    final body = <String, dynamic>{
      'model': usedModel,
      'stream': true,
      'temperature': temperature ?? 0.7,
      'messages': messages.map(_encodeMessage).toList(),
    };

    final url = _resolveUrl();
    final Response<ResponseBody> resp;
    try {
      resp = await _dio.post<ResponseBody>(
        url,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
          responseType: ResponseType.stream,
        ),
      );
    } on DioException catch (e) {
      throw LlmException(
        e.message ?? '网络错误',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }

    final stream = resp.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    final buffer = StringBuffer();
    await for (final raw in stream) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload == '[DONE]') {
        yield LlmChunk('', done: true);
        return;
      }
      Map<String, dynamic> json;
      try {
        json = jsonDecode(payload) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      final choices = json['choices'];
      if (choices is List && choices.isNotEmpty) {
        final delta = choices.first['delta'];
        if (delta is Map<String, dynamic>) {
          final content = delta['content'];
          if (content is String && content.isNotEmpty) {
            buffer.write(content);
            yield LlmChunk(content);
          }
        }
      }
    }
    if (buffer.isEmpty) {
      // Some providers emit non-SSE responses; nothing to do.
    }
    yield LlmChunk('', done: true);
  }

  /// Quick non-streaming sanity check for the settings page.
  ///
  /// Uses non-streaming JSON because some providers (especially Chinese
  /// vendors) return error bodies that aren't readable when the request is
  /// `responseType: stream`.
  Future<String> testEcho() async {
    if (!config.isComplete) {
      throw const LlmException('LLM 未配置完整');
    }
    final url = _resolveUrl();
    final body = <String, dynamic>{
      'model': config.chatModel,
      'stream': false,
      'temperature': 0,
      'messages': [
        {'role': 'system', 'content': '你是连接测试助手，请直接回复："OK"。'},
        {'role': 'user', 'content': 'ping'},
      ],
    };

    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        url,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
      );
      final data = resp.data;
      if (data == null) return '(空响应)';
      final choices = data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final msg = choices.first['message'];
        if (msg is Map && msg['content'] is String) {
          return (msg['content'] as String).trim();
        }
      }
      // 非标准格式，原样返回前 120 字以便排查
      return _truncate(jsonEncode(data), 120);
    } on DioException catch (e) {
      throw LlmException(_formatDioError(e),
          statusCode: e.response?.statusCode, cause: e);
    }
  }

  String _formatDioError(DioException e) {
    final code = e.response?.statusCode;
    final body = e.response?.data;
    String detail;
    try {
      detail = body is String
          ? body
          : (body == null ? '' : jsonEncode(body));
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

  /// GET {baseURL}/models — 返回服务端公开的模型 id 列表。
  Future<List<String>> listModels() async {
    if (config.baseUrl.isEmpty || config.apiKey.isEmpty) {
      throw const LlmException('请先填 baseURL 与 API Key');
    }
    final url = _resolveModelsUrl();
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Accept': 'application/json',
          },
          responseType: ResponseType.json,
        ),
      );
      final data = resp.data;
      final list = data?['data'];
      if (list is List) {
        return list
            .map((e) {
              if (e is Map && e['id'] != null) return e['id'].toString();
              return e.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList()
          ..sort();
      }
      return const [];
    } on DioException catch (e) {
      throw LlmException(_formatDioError(e),
          statusCode: e.response?.statusCode, cause: e);
    }
  }
}

final llmClientProvider = Provider<LlmClient?>((ref) {
  final cfg = ref.watch(llmConfigProvider).valueOrNull;
  if (cfg == null || !cfg.isComplete) return null;
  return OpenAICompatibleClient(cfg);
});
