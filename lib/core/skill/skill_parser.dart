import 'package:yaml/yaml.dart';

import 'skill.dart';

class SkillParser {
  /// 解析 `---\n<yaml>\n---\n<body>` 形态的 markdown。
  ///
  /// 没有 frontmatter 也允许：直接把整段当 body，frontmatter 留空。
  static Skill parse(String name, String source) {
    final text = source.replaceAll('\r\n', '\n').trim();

    if (!text.startsWith('---')) {
      return Skill(name: name, frontmatter: const {}, body: text);
    }

    final rest = text.substring(3); // 去掉首部 ---
    final endIdx = rest.indexOf('\n---');
    if (endIdx < 0) {
      return Skill(name: name, frontmatter: const {}, body: text);
    }

    final frontRaw = rest.substring(0, endIdx).trim();
    final body = rest.substring(endIdx + '\n---'.length).trimLeft();

    Map<String, dynamic> front;
    try {
      final yaml = loadYaml(frontRaw);
      front = _toMap(yaml);
    } catch (_) {
      front = const {};
    }

    return Skill(name: name, frontmatter: front, body: body);
  }

  static Map<String, dynamic> _toMap(dynamic yaml) {
    if (yaml is YamlMap) {
      return yaml.map((k, v) => MapEntry(k.toString(), _convert(v)));
    }
    if (yaml is Map) {
      return yaml.map((k, v) => MapEntry(k.toString(), _convert(v)));
    }
    return const {};
  }

  static dynamic _convert(dynamic v) {
    if (v is YamlMap) return _toMap(v);
    if (v is YamlList) return v.map(_convert).toList();
    return v;
  }
}
