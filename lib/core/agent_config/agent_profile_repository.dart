import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 用户编辑的 `profile.md`：写在本地文档目录，不打包进 app。
///
/// 类比 Claude Code 的 `~/.claude/CLAUDE.md`：app 启动时读，
/// 在设置页里编辑保存，立即对下一句对话生效。
class AgentProfileRepository {
  static const _filename = 'profile.md';
  static const _maxChars = 4000; // 拼到 system prompt 时的硬上限

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    final agentDir = Directory(p.join(dir.path, 'agent'));
    if (!await agentDir.exists()) {
      await agentDir.create(recursive: true);
    }
    return File(p.join(agentDir.path, _filename));
  }

  /// 读出 profile.md 内容；不存在则返回空字符串。
  Future<String> read() async {
    try {
      final f = await _file();
      if (!await f.exists()) return '';
      return await f.readAsString();
    } catch (_) {
      return '';
    }
  }

  Future<void> write(String content) async {
    final f = await _file();
    final trimmed = content.length > _maxChars
        ? content.substring(0, _maxChars)
        : content;
    await f.writeAsString(trimmed);
  }

  Future<void> delete() async {
    try {
      final f = await _file();
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// 在 profile.md 末尾追加一条 markdown bullet line。
  ///
  /// - 自动确保有 `# 我` 标题段
  /// - 重复行不会再加（按 trim 比对）
  /// - 返回最终的 profile 全文（调用方可用来回放/撤销）
  Future<String> appendLine(String line) async {
    final raw = await read();
    final note = line.trim();
    if (note.isEmpty) return raw;

    final body = raw.trim();
    final bullet = note.startsWith('-') ? note : '- $note';

    // 已有这一行就不加
    final existing = body.split('\n').map((l) => l.trim()).toSet();
    if (existing.contains(bullet)) return raw;

    final composed = body.isEmpty
        ? '# 我\n\n$bullet\n'
        : (body.contains('# 我') ? '$body\n$bullet\n' : '$body\n\n$bullet\n');
    await write(composed);
    return composed;
  }

  /// 删掉 profile.md 里跟 [match] 关键词相关的第一条 bullet。
  /// 返回 (newContent, removedLine?)；没命中时 removedLine = null。
  Future<({String content, String? removed})> removeLine(String match) async {
    final raw = await read();
    final m = match.trim();
    if (m.isEmpty || raw.isEmpty) return (content: raw, removed: null);

    final lines = raw.split('\n');
    int hitIdx = -1;
    String? removed;
    for (int i = 0; i < lines.length; i++) {
      final t = lines[i].trim();
      if (!t.startsWith('-')) continue;
      if (t.contains(m)) {
        hitIdx = i;
        removed = lines[i];
        break;
      }
    }
    if (hitIdx < 0) return (content: raw, removed: null);
    lines.removeAt(hitIdx);
    final composed = lines.join('\n');
    await write(composed);
    return (content: composed, removed: removed);
  }
}

final agentProfileRepositoryProvider = Provider<AgentProfileRepository>(
  (_) => AgentProfileRepository(),
);

class AgentProfileController extends AsyncNotifier<String> {
  late final AgentProfileRepository _repo;

  @override
  Future<String> build() async {
    _repo = ref.read(agentProfileRepositoryProvider);
    return _repo.read();
  }

  Future<void> save(String content) async {
    await _repo.write(content);
    state = AsyncData(content);
  }

  Future<void> clear() async {
    await _repo.delete();
    state = const AsyncData('');
  }

  /// 给 voice tool 用：追加一条偏好。返回追加后的全文（也写进 state）。
  Future<String> appendLine(String line) async {
    final next = await _repo.appendLine(line);
    state = AsyncData(next);
    return next;
  }

  /// 给 voice tool 用：模糊匹配删一条。返回被删掉的 line（撤销用）。
  Future<String?> removeLine(String match) async {
    final r = await _repo.removeLine(match);
    state = AsyncData(r.content);
    return r.removed;
  }
}

final agentProfileProvider =
    AsyncNotifierProvider<AgentProfileController, String>(
        AgentProfileController.new);
