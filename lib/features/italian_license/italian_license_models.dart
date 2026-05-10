/// 意大利驾照题目结构化结果。
enum LicenseFormat {
  trueFalse,
  multipleChoice,
  unknown;

  static LicenseFormat parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'true_false':
      case 'truefalse':
      case 'vero_falso':
        return LicenseFormat.trueFalse;
      case 'multiple_choice':
      case 'multiplechoice':
      case 'choice':
        return LicenseFormat.multipleChoice;
      default:
        return LicenseFormat.unknown;
    }
  }
}

class LicenseOption {
  final String letter;
  final String it;
  final String zh;

  const LicenseOption({
    required this.letter,
    required this.it,
    required this.zh,
  });

  Map<String, dynamic> toJson() => {'letter': letter, 'it': it, 'zh': zh};
}

class LicenseVocab {
  final String it;
  final String zh;
  final String note;

  const LicenseVocab({
    required this.it,
    required this.zh,
    required this.note,
  });

  Map<String, dynamic> toJson() => {'it': it, 'zh': zh, 'note': note};
}

class ItalianLicenseResult {
  final String questionIt;
  final String questionZh;
  final LicenseFormat format;
  final List<LicenseOption> options;
  final String answer;
  final String explanationZh;
  final List<LicenseVocab> vocabulary;
  final List<String> grammarNotes;
  final String mnemonic;

  /// 模型如果没遵守 JSON 格式，原文留底。
  final String rawText;

  const ItalianLicenseResult({
    required this.questionIt,
    required this.questionZh,
    required this.format,
    required this.options,
    required this.answer,
    required this.explanationZh,
    required this.vocabulary,
    required this.grammarNotes,
    required this.mnemonic,
    required this.rawText,
  });

  Map<String, dynamic> toJson() => {
        'question_it': questionIt,
        'question_zh': questionZh,
        'format': format.name,
        'options': options.map((o) => o.toJson()).toList(),
        'answer': answer,
        'explanation_zh': explanationZh,
        'vocabulary': vocabulary.map((v) => v.toJson()).toList(),
        'grammar_notes': grammarNotes,
        'mnemonic': mnemonic,
      };
}
