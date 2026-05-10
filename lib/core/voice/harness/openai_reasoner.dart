import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../llm/openai_compatible_client.dart';
import '../../llm/types.dart';
import '../voice_types.dart';
import 'harness_input.dart';
import 'reasoner.dart';

/// 包装 [OpenAICompatibleClient] —— 吃 [TextHarnessInput]（text + 可选图片）。
///
/// system prompt 已经按 JSON intent 协议拼好；这里负责：
/// - 拼 user message（text + image part）
/// - 选 chatModel / visionModel
/// - 解 JSON 出 [AgentResponse]
class OpenAIReasoner implements HarnessReasoner {
  final OpenAICompatibleClient client;

  const OpenAIReasoner(this.client);

  @override
  String get name => 'openai';

  @override
  bool canHandle(HarnessInput input) => input is TextHarnessInput;

  @override
  Future<AgentResponse> reason({
    required HarnessInput input,
    required String systemPrompt,
    PageContext? pageContext,
  }) async {
    if (input is! TextHarnessInput) {
      throw ReasonerException('OpenAIReasoner cannot handle ${input.runtimeType}');
    }

    final fullSystem = pageContext == null
        ? systemPrompt
        : '$systemPrompt\n\n当前页面上下文：'
            '${jsonEncode({"kind": pageContext.kind, "payload": pageContext.payload})}';

    final userParts = <MessagePart>[];
    if (input.text.trim().isNotEmpty) userParts.add(TextPart(input.text));
    if (input.hasImage) userParts.add(ImagePart(input.image!));

    final messages = <LlmMessage>[
      LlmMessage.system(fullSystem),
      LlmMessage(LlmRole.user, userParts),
    ];

    String content;
    try {
      content = await client.chatOnceJson(
        messages,
        needsVision: input.hasImage,
        temperature: 0.2,
      );
    } on LlmException catch (e) {
      throw ReasonerException(
        e.message,
        statusCode: e.statusCode,
        cause: e,
      );
    }

    final parsed = _extractJson(content);
    if (parsed == null) {
      debugPrint('[OpenAIReasoner] no JSON in: ${_trim(content, 200)}');
      return AgentResponse(speakText: content.trim(), transcript: input.text);
    }
    final action = parsed['action'];
    final args = parsed['args'];
    final speak = parsed['speak'];
    return AgentResponse(
      toolName: action is String && action.isNotEmpty ? action : null,
      args: args is Map<String, dynamic>
          ? args
          : (args is Map ? Map<String, dynamic>.from(args) : const {}),
      speakText: speak is String && speak.isNotEmpty
          ? speak
          : content.trim(),
      transcript: input.text,
    );
  }

  Map<String, dynamic>? _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final json = jsonDecode(text.substring(start, end + 1));
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return null;
  }

  String _trim(String s, int n) => s.length <= n ? s : '${s.substring(0, n)}…';
}
