import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'skill.dart';
import 'skill_parser.dart';

/// 内置 skill 加载器（`assets/skills/<name>/SKILL.md`）。
///
/// 后续 M2 阶段会扩展为 assets + 用户文档目录合并 + watch 变更，
/// 当前阶段只支持从 assets 读。
class SkillLoader {
  /// 简单的内存缓存，避免每次都去解析 yaml。
  final Map<String, Skill> _cache = {};

  Future<Skill> load(String name) async {
    final cached = _cache[name];
    if (cached != null) return cached;

    final path = 'assets/skills/$name/SKILL.md';
    final raw = await rootBundle.loadString(path);
    final skill = SkillParser.parse(name, raw);
    _cache[name] = skill;
    return skill;
  }

  void invalidate([String? name]) {
    if (name == null) {
      _cache.clear();
    } else {
      _cache.remove(name);
    }
  }
}

final skillLoaderProvider = Provider<SkillLoader>((_) => SkillLoader());
