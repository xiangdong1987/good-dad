import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'italian_license_models.dart';

/// 纯 Dart 工具：图片压缩、宽容 JSON 解析。
class ItalianLicensePrompt {
  /// 把题目截图压到 ≤1280px 宽 / JPEG q75。
  static Uint8List compressImage(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final resized = decoded.width > 1280
        ? img.copyResize(decoded, width: 1280)
        : decoded;
    return Uint8List.fromList(img.encodeJpg(resized, quality: 75));
  }

  /// 宽容 JSON 解析：先直解；失败找第一个 {...} 块再试；都不行 unknown。
  static ItalianLicenseResult parseModelOutput(String raw) {
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

    return ItalianLicenseResult(
      questionIt: (json['question_it'] ?? '').toString(),
      questionZh: (json['question_zh'] ?? '').toString(),
      format: LicenseFormat.parse(json['format']?.toString()),
      options: _parseOptions(json['options']),
      answer: (json['answer'] ?? '').toString().trim(),
      explanationZh: (json['explanation_zh'] ?? '').toString(),
      vocabulary: _parseVocab(json['vocabulary']),
      grammarNotes: _asStringList(json['grammar_notes']),
      mnemonic: (json['mnemonic'] ?? '').toString(),
      rawText: raw,
    );
  }

  static List<LicenseOption> _parseOptions(dynamic v) {
    if (v is! List) return const [];
    return v.whereType<Map>().map((m) {
      return LicenseOption(
        letter: (m['letter'] ?? '').toString(),
        it: (m['it'] ?? '').toString(),
        zh: (m['zh'] ?? '').toString(),
      );
    }).where((o) => o.letter.isNotEmpty || o.it.isNotEmpty).toList();
  }

  static List<LicenseVocab> _parseVocab(dynamic v) {
    if (v is! List) return const [];
    return v.whereType<Map>().map((m) {
      return LicenseVocab(
        it: (m['it'] ?? '').toString(),
        zh: (m['zh'] ?? '').toString(),
        note: (m['note'] ?? '').toString(),
      );
    }).where((vv) => vv.it.isNotEmpty).toList();
  }

  static List<String> _asStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }
}
