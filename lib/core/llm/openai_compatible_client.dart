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

  String _resolveUrl() {
    var base = config.baseUrl.trim();
    if (base.isEmpty) {
      throw const LlmException('未配置 baseURL');
    }
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.endsWith('/chat/completions')) return base;
    if (!base.endsWith('/v1') && !base.contains('/v')) base = '$base/v1';
    return '$base/chat/completions';
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
  Future<String> testEcho() async {
    final result = await chatOnce(
      [
        LlmMessage.system('你是一个连接测试助手，请直接返回："OK"。'),
        LlmMessage.user('ping'),
      ],
      temperature: 0,
    );
    return result.text.trim();
  }
}

final llmClientProvider = Provider<LlmClient?>((ref) {
  final cfg = ref.watch(llmConfigProvider).valueOrNull;
  if (cfg == null || !cfg.isComplete) return null;
  return OpenAICompatibleClient(cfg);
});
