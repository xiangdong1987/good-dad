/// 一份从 SKILL.md 解析出来的技能定义。
class Skill {
  final String name;
  final Map<String, dynamic> frontmatter;

  /// markdown body（去掉 frontmatter 后的全部内容）
  final String body;

  const Skill({
    required this.name,
    required this.frontmatter,
    required this.body,
  });

  String get title => (frontmatter['title'] as String?) ?? name;

  String get description =>
      (frontmatter['description'] as String?) ?? '';

  double get temperature =>
      (_dig<num>(['model', 'temperature']))?.toDouble() ?? 0.7;

  bool get needsVision => _dig<String>(['model', 'capability']) == 'vision';

  String get outputFormat =>
      _dig<String>(['output', 'format']) ?? 'plain';

  /// 取 frontmatter 里嵌套字段，比如 ['model','temperature']
  T? _dig<T>(List<String> path) {
    dynamic cur = frontmatter;
    for (final k in path) {
      if (cur is Map && cur.containsKey(k)) {
        cur = cur[k];
      } else {
        return null;
      }
    }
    return cur is T ? cur : null;
  }
}
