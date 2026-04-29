/// 食物可食性判定结果（结构化）。
enum FoodVerdict {
  safe,
  caution,
  avoid,
  unknown;

  static FoodVerdict parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'safe':
        return FoodVerdict.safe;
      case 'caution':
        return FoodVerdict.caution;
      case 'avoid':
        return FoodVerdict.avoid;
      default:
        return FoodVerdict.unknown;
    }
  }
}

class FoodSafetyResult {
  final FoodVerdict verdict;
  final String name;
  final String reason;
  final List<String> dos;
  final List<String> donts;
  final List<String> alternatives;

  /// 模型如果没遵守 JSON 格式，原文留底（可显示）。
  final String rawText;

  const FoodSafetyResult({
    required this.verdict,
    required this.name,
    required this.reason,
    required this.dos,
    required this.donts,
    required this.alternatives,
    required this.rawText,
  });

  Map<String, dynamic> toJson() => {
        'verdict': verdict.name,
        'name': name,
        'reason': reason,
        'dos': dos,
        'donts': donts,
        'alternatives': alternatives,
      };
}
