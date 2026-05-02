import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/profile/profile.dart';
import '../../core/skill/skill_output.dart';
import '../../core/skill/skill_runner.dart';
import 'italian_vocab_models.dart';

class ItalianVocabError implements Exception {
  final String message;
  const ItalianVocabError(this.message);
  @override
  String toString() => message;
}

class ItalianVocabRunner {
  final SkillRunner runner;
  ItalianVocabRunner({required this.runner});

  /// 取最多 8 个词喂给 LLM，返回学习卡。
  Future<StudySession> run({
    required List<SavedVocab> words,
    required FamilyProfile profile,
  }) async {
    if (words.isEmpty) {
      throw const ItalianVocabError('单词表是空的，先去拍题或加几个词');
    }
    final picked = words.take(8).toList();
    final lines = <String>[
      '请为下面这些意大利语词各出一张学习卡：',
      ...picked
          .asMap()
          .entries
          .map((e) => e.value.toPromptLine(e.key + 1)),
    ];
    final text = lines.join('\n');

    SkillRunResult res;
    try {
      res = await runner.run(
        'italian-vocab-study',
        text: text,
        profile: profile,
      );
    } on SkillRunError catch (e) {
      throw ItalianVocabError(e.message);
    }

    return parseSession(res.rawText);
  }

  static StudySession parseSession(String raw) {
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
    final cards = <StudyCard>[];
    if (json != null && json['cards'] is List) {
      for (final c in (json['cards'] as List).whereType<Map>()) {
        final card = _cardFromJson(c.cast<String, dynamic>());
        if (card != null) cards.add(card);
      }
    }
    return StudySession(cards: cards, rawText: raw);
  }

  static StudyCard? _cardFromJson(Map<String, dynamic> m) {
    final wordIt = (m['word_it'] ?? '').toString().trim();
    if (wordIt.isEmpty) return null;
    final opts = (m['quiz_options'] is List)
        ? (m['quiz_options'] as List)
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];
    return StudyCard(
      wordIt: wordIt,
      wordZh: (m['word_zh'] ?? '').toString(),
      exampleIt: (m['example_it'] ?? '').toString(),
      exampleZh: (m['example_zh'] ?? '').toString(),
      quizQuestionIt: (m['quiz_question_it'] ?? '').toString(),
      quizOptions: opts,
      quizAnswer: (m['quiz_answer'] ?? '').toString().trim(),
      tip: (m['tip'] ?? '').toString(),
    );
  }
}

final italianVocabRunnerProvider = Provider<ItalianVocabRunner?>((ref) {
  final runner = ref.watch(skillRunnerProvider);
  if (runner == null) return null;
  return ItalianVocabRunner(runner: runner);
});
