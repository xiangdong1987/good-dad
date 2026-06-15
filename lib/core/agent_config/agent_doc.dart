import '../skill/skill_parser.dart';

/// AGENT.md 的解析结果。
///
/// AGENT.md 跟 SKILL.md 同种格式（YAML frontmatter + markdown body），
/// 但语义不同：AGENT 是 voice/text agent 的人设 + 工具协议，SKILL 是单一技能。
class AgentDoc {
  /// markdown 主体（system prompt 默认人设 + 协议说明）。
  final String body;

  /// frontmatter 原始 map。
  final Map<String, dynamic> frontmatter;

  const AgentDoc({required this.body, required this.frontmatter});

  static const empty = AgentDoc(body: '', frontmatter: {});

  /// memory 注入用的 keys 模板（如 ['self.*', 'baby.*']）。
  List<String> get memoryKeys {
    final ctx = frontmatter['context'];
    if (ctx is Map) {
      final keys = ctx['memory_keys'];
      if (keys is List) return keys.map((e) => e.toString()).toList();
    }
    return const [];
  }

  /// memory 取 top-K 条。
  int get memoryTopK {
    final ctx = frontmatter['context'];
    if (ctx is Map) {
      final v = ctx['memory_topk'];
      if (v is int) return v;
      if (v is num) return v.toInt();
    }
    return 8;
  }

  /// agent speak 的最大字数（拼 system prompt 时给模型一个明确上限）。
  int get maxSpeakChars {
    final v = frontmatter['max_speak_chars'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 200;
  }

  /// 静态方法：解析一段 markdown 文本（字符串）成 [AgentDoc]。
  static AgentDoc parse(String source) {
    final skill = SkillParser.parse('voice-agent', source);
    return AgentDoc(body: skill.body, frontmatter: skill.frontmatter);
  }
}
