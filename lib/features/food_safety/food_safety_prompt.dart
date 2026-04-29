import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../core/llm/types.dart';
import '../../core/profile/profile.dart';
import '../../core/skill/skill.dart';
import 'food_safety_models.dart';

/// 纯 Dart 工具：图片压缩、prompt 拼装、宽容 JSON 解析。
/// 不依赖 Flutter / Riverpod / drift，CLI 与单元测试都能直接用。
class FoodSafetyPrompt {
  /// 把任意输入图片压缩到 ≤1280px 宽 / JPEG q75。
  static Uint8List compressImage(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final resized = decoded.width > 1280
        ? img.copyResize(decoded, width: 1280)
        : decoded;
    return Uint8List.fromList(img.encodeJpg(resized, quality: 75));
  }

  static List<LlmMessage> buildMessages(
    Skill skill,
    FamilyProfile profile,
    Uint8List bytes,
    String? userText,
  ) {
    final ctxLines = <String>[
      '## 家庭信息（请基于此回答）',
      if (profile.dadName != null) '- 爸爸（用户）希望被叫：${profile.dadName}',
      if (profile.momName != null) '- 妈妈希望被叫：${profile.momName}',
      if (profile.currentWeek() != null)
        '- 当前孕周：${profile.currentWeek()} 周（共 40 周）',
    ];

    final systemPrompt = [
      skill.body.trim(),
      '',
      ctxLines.join('\n'),
      '',
      '严格只输出符合上方规范的纯 JSON。不要 markdown 围栏，不要解释。',
    ].join('\n');

    final userPart = (userText ?? '').trim();
    return [
      LlmMessage.system(systemPrompt),
      LlmMessage(
        LlmRole.user,
        [
          ImagePart(bytes),
          TextPart(userPart.isEmpty ? '这个能吃吗？' : userPart),
        ],
      ),
    ];
  }

  /// 宽容 JSON 解析：先直解；失败时找第一个 {...} 块再试；都不行就 unknown。
  static FoodSafetyResult parseModelOutput(String raw) {
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start >= 0 && end > start) {
        try {
          json =
              jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
        } catch (_) {}
      }
    }
    json ??= const {};

    List<String> asList(dynamic v) {
      if (v is List) {
        return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
      return const [];
    }

    return FoodSafetyResult(
      verdict: FoodVerdict.parse(json['verdict']?.toString()),
      name: (json['name'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      dos: asList(json['dos']),
      donts: asList(json['donts']),
      alternatives: asList(json['alternatives']),
      rawText: raw,
    );
  }
}
