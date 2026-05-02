import 'dart:convert';

import '../../core/memory/memory.dart';

/// 一张「单词学习卡」——LLM 一次性出一组。
class StudyCard {
  final String wordIt;
  final String wordZh;
  final String exampleIt;
  final String exampleZh;
  final String quizQuestionIt;
  final List<String> quizOptions;
  final String quizAnswer;
  final String tip;

  const StudyCard({
    required this.wordIt,
    required this.wordZh,
    required this.exampleIt,
    required this.exampleZh,
    required this.quizQuestionIt,
    required this.quizOptions,
    required this.quizAnswer,
    required this.tip,
  });

  Map<String, dynamic> toJson() => {
        'word_it': wordIt,
        'word_zh': wordZh,
        'example_it': exampleIt,
        'example_zh': exampleZh,
        'quiz_question_it': quizQuestionIt,
        'quiz_options': quizOptions,
        'quiz_answer': quizAnswer,
        'tip': tip,
      };
}

class StudySession {
  final List<StudyCard> cards;
  final String rawText;
  const StudySession({required this.cards, required this.rawText});
}

/// 从 memory.body 反解出 vocab 三元组（参考 ItalianLicenseVocab.toEntry 的写入格式）。
class SavedVocab {
  final int memoryId;
  final String it;
  final String zh;
  final String note;

  const SavedVocab({
    required this.memoryId,
    required this.it,
    required this.zh,
    required this.note,
  });

  /// memory.body 形如：
  /// ```
  /// it: divieto di sosta
  /// zh: 禁止停车
  /// note: ...
  /// source: italian-license
  /// ```
  static SavedVocab fromMemory(MemoryEntry e) {
    final lines = const LineSplitter().convert(e.body);
    String? it, zh, note;
    for (final line in lines) {
      final idx = line.indexOf(':');
      if (idx < 0) continue;
      final key = line.substring(0, idx).trim().toLowerCase();
      final val = line.substring(idx + 1).trim();
      switch (key) {
        case 'it':
          it = val;
          break;
        case 'zh':
          zh = val;
          break;
        case 'note':
          note = val;
          break;
      }
    }
    return SavedVocab(
      memoryId: e.id ?? -1,
      it: it ?? e.description,
      zh: zh ?? '',
      note: note ?? '',
    );
  }

  String toPromptLine(int index) {
    final notePart = note.isEmpty ? '' : ' ($note)';
    final zhPart = zh.isEmpty ? '' : ' — $zh';
    return '$index. $it$zhPart$notePart';
  }
}
