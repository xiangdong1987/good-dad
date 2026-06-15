import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'llm_log_entry.dart';

/// LLM 调用日志存储。
///
/// 文件路径：`getApplicationSupportDirectory()/llm_log.jsonl`
/// 每行一条 JSON。append-only，超出 [_maxEntries] 时按 LRU 砍掉头部。
///
/// 不用 drift 表：避免 schema migration；用户清完整文件就行。
class LlmLogRepository {
  static const _filename = 'llm_log.jsonl';
  static const _maxEntries = 200;

  /// 写文件锁，防止并发 append 互相覆盖。
  Completer<void>? _writeLock;

  /// UI 订阅用：写入后 fire 一下。
  final StreamController<void> _changes =
      StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _filename));
  }

  Future<void> append(LlmLogEntry entry) async {
    final f = await _file();
    // 简单串行化
    while (_writeLock != null) {
      try {
        await _writeLock!.future;
      } catch (_) {}
    }
    final lock = Completer<void>();
    _writeLock = lock;
    try {
      final line = '${jsonEncode(entry.toJson())}\n';
      await f.writeAsString(line, mode: FileMode.append, flush: true);
      await _trimIfNeeded(f);
      _changes.add(null);
    } catch (e) {
      debugPrint('[LlmLog] append failed: $e');
    } finally {
      lock.complete();
      _writeLock = null;
    }
  }

  Future<List<LlmLogEntry>> readAll() async {
    final f = await _file();
    if (!await f.exists()) return const [];
    try {
      final lines = await f.readAsLines();
      final out = <LlmLogEntry>[];
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final j = jsonDecode(line) as Map<String, dynamic>;
          out.add(LlmLogEntry.fromJson(j));
        } catch (_) {
          // 单行损坏不影响别的
        }
      }
      return out;
    } catch (e) {
      debugPrint('[LlmLog] read failed: $e');
      return const [];
    }
  }

  Future<void> clear() async {
    final f = await _file();
    if (await f.exists()) {
      try {
        await f.writeAsString('', flush: true);
      } catch (_) {}
    }
    _changes.add(null);
  }

  Future<void> _trimIfNeeded(File f) async {
    try {
      final lines = await f.readAsLines();
      if (lines.length <= _maxEntries) return;
      final keep = lines.sublist(lines.length - _maxEntries);
      await f.writeAsString('${keep.join('\n')}\n', flush: true);
    } catch (e) {
      debugPrint('[LlmLog] trim failed: $e');
    }
  }
}

final llmLogRepositoryProvider = Provider<LlmLogRepository>((ref) {
  final repo = LlmLogRepository();
  return repo;
});

/// UI 页订阅 —— 写入后自动重 build。
final llmLogStreamProvider = StreamProvider<List<LlmLogEntry>>((ref) async* {
  final repo = ref.watch(llmLogRepositoryProvider);
  yield await repo.readAll();
  await for (final _ in repo.changes) {
    yield await repo.readAll();
  }
});
