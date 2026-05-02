import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/profile/profile.dart';
import '../../core/skill/skill_output.dart';
import '../../core/skill/skill_runner.dart';
import 'italian_lookup_models.dart';

class ItalianLookupError implements Exception {
  final String message;
  const ItalianLookupError(this.message);
  @override
  String toString() => message;
}

class ItalianLookupRunner {
  final SkillRunner runner;
  ItalianLookupRunner({required this.runner});

  Future<LookupResult> run({
    required String query,
    required FamilyProfile profile,
  }) async {
    final q = query.trim();
    if (q.isEmpty) {
      throw const ItalianLookupError('请输入要查的词');
    }

    SkillRunResult res;
    try {
      res = await runner.run(
        'italian-lookup',
        text: q,
        profile: profile,
      );
    } on SkillRunError catch (e) {
      throw ItalianLookupError(e.message);
    }

    return parseResult(res.rawText);
  }

  static LookupResult parseResult(String raw) {
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start >= 0 && end > start) {
        try {
          json = jsonDecode(raw.substring(start, end + 1))
              as Map<String, dynamic>;
        } catch (_) {}
      }
    }
    json ??= const {};

    return LookupResult(
      wordIt: (json['word_it'] ?? '').toString(),
      wordZh: (json['word_zh'] ?? '').toString(),
      pos: (json['pos'] ?? '').toString(),
      examples: _parseExamples(json['examples']),
      grammar: (json['grammar'] ?? '').toString(),
      related: _asStringList(json['related']),
      notFound: json['not_found'] == true,
      rawText: raw,
    );
  }

  static List<LookupExample> _parseExamples(dynamic v) {
    if (v is! List) return const [];
    return v.whereType<Map>().map((m) {
      return LookupExample(
        it: (m['it'] ?? '').toString(),
        zh: (m['zh'] ?? '').toString(),
      );
    }).where((e) => e.it.isNotEmpty).toList();
  }

  static List<String> _asStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }
}

final italianLookupRunnerProvider = Provider<ItalianLookupRunner?>((ref) {
  final runner = ref.watch(skillRunnerProvider);
  if (runner == null) return null;
  return ItalianLookupRunner(runner: runner);
});
