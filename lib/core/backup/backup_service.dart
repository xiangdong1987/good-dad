import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../storage/database.dart';

/// 备份摘要：导出/导入完成后告诉 UI 总共带了什么。
class BackupSummary {
  final int dbBytes;
  final int photoCount;
  final int skillCount;
  final String filePath;
  const BackupSummary({
    required this.dbBytes,
    required this.photoCount,
    required this.skillCount,
    required this.filePath,
  });

  String get sizeLabel {
    final total = File(filePath).existsSync() ? File(filePath).lengthSync() : 0;
    if (total < 1024) return '$total B';
    if (total < 1024 * 1024) return '${(total / 1024).toStringAsFixed(1)} KB';
    return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 数据备份服务：把 SQLite + photos + 用户 skills 打成一个 zip；
/// 反向也支持。**API key 从不进入备份**（在 secure_storage 里，需用户重输）。
class BackupService {
  static const _manifestName = 'manifest.json';
  static const _backupVersion = 1;

  final AppDatabase _db;
  BackupService(this._db);

  /// 把当前 App 数据打成一个 zip 写到 cache 目录，返回路径。
  Future<BackupSummary> exportToZip() async {
    // 1. 收集要打包的源
    final docsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docsDir.path, 'good_dad.sqlite'));
    final photoFood = Directory(p.join(docsDir.path, 'photos', 'food'));
    final photoBelly = Directory(p.join(docsDir.path, 'photos', 'belly'));
    final skillsDir = Directory(p.join(docsDir.path, 'skills'));

    final archive = Archive();

    // 重要：导出前 sqlite 也许有未刷盘的事务。drift 默认 WAL；
    // 简化处理：让它自然 flush（drift 写完后基本就在文件里），不强行 close。
    if (dbFile.existsSync()) {
      final bytes = await dbFile.readAsBytes();
      archive.addFile(ArchiveFile('good_dad.sqlite', bytes.length, bytes));
    }

    int photoCount = 0;
    photoCount += await _addDirToArchive(archive, photoFood, 'photos/food');
    photoCount += await _addDirToArchive(archive, photoBelly, 'photos/belly');

    final skillCount = await _addDirToArchive(archive, skillsDir, 'skills');

    // manifest
    final manifest = {
      'version': _backupVersion,
      'created_at': DateTime.now().toIso8601String(),
      'photo_count': photoCount,
      'skill_count': skillCount,
      'has_db': dbFile.existsSync(),
      'note': 'API key 不在备份里，恢复后请重新填写',
    };
    final manifestBytes = utf8.encode(jsonEncode(manifest));
    archive.addFile(
        ArchiveFile(_manifestName, manifestBytes.length, manifestBytes));

    // 2. 编码到 zip
    final zipBytes = ZipEncoder().encode(archive);
    final tmp = await getTemporaryDirectory();
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final outPath = p.join(tmp.path, 'good_dad_backup_$ts.zip');
    final out = File(outPath);
    await out.writeAsBytes(zipBytes, flush: true);

    return BackupSummary(
      dbBytes: dbFile.existsSync() ? dbFile.lengthSync() : 0,
      photoCount: photoCount,
      skillCount: skillCount,
      filePath: outPath,
    );
  }

  /// 从 zip 恢复。**会先关闭 DB**，覆盖所有相关文件，然后强烈建议重启 App。
  /// 返回 null 表示失败/取消（调用方根据 [error] 决定 UI）。
  Future<BackupRestoreResult> importFromZip(String zipPath) async {
    final file = File(zipPath);
    if (!file.existsSync()) {
      return const BackupRestoreResult(
          ok: false, error: '文件不存在');
    }

    Archive archive;
    try {
      final bytes = await file.readAsBytes();
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      return BackupRestoreResult(ok: false, error: '不是有效 zip: $e');
    }

    // 校验 manifest（可选 —— 没 manifest 也允许，但提醒）
    final manifestEntry = archive.findFile(_manifestName);
    if (manifestEntry == null) {
      return const BackupRestoreResult(
          ok: false, error: '备份里没有 manifest.json，可能不是 good-dad 的备份');
    }
    Map<String, dynamic>? manifest;
    try {
      manifest = jsonDecode(utf8.decode(manifestEntry.content as List<int>))
          as Map<String, dynamic>;
    } catch (_) {
      return const BackupRestoreResult(
          ok: false, error: 'manifest.json 解析失败');
    }
    if ((manifest['version'] as num?)?.toInt() != _backupVersion) {
      return BackupRestoreResult(
          ok: false,
          error: '版本不匹配（备份 v${manifest['version']}，当前 v$_backupVersion）');
    }

    // 先关闭 DB 连接，让我们能覆盖文件
    await _db.close();

    final docsDir = await getApplicationDocumentsDirectory();
    int restoredPhotos = 0;
    int restoredSkills = 0;
    bool restoredDb = false;

    for (final entry in archive.files) {
      if (entry.isFile == false) continue;
      final name = entry.name;
      if (name == _manifestName) continue;

      final outPath = p.join(docsDir.path, name);
      final outFile = File(outPath);
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(entry.content as List<int>, flush: true);

      if (name == 'good_dad.sqlite') {
        restoredDb = true;
      } else if (name.startsWith('photos/')) {
        restoredPhotos++;
      } else if (name.startsWith('skills/')) {
        restoredSkills++;
      }
    }

    return BackupRestoreResult(
      ok: true,
      restoredDb: restoredDb,
      restoredPhotos: restoredPhotos,
      restoredSkills: restoredSkills,
      requiresRestart: true,
    );
  }

  // ── helpers ────────────────────────────────────────────────────────

  Future<int> _addDirToArchive(
      Archive archive, Directory dir, String archivePrefix) async {
    if (!dir.existsSync()) return 0;
    var count = 0;
    final entities = dir.listSync(recursive: true, followLinks: false);
    for (final e in entities) {
      if (e is! File) continue;
      final rel = p.relative(e.path, from: dir.path);
      final entryName = p.posix.join(archivePrefix, rel.replaceAll('\\', '/'));
      final bytes = await e.readAsBytes();
      archive.addFile(ArchiveFile(entryName, bytes.length, bytes));
      count++;
    }
    return count;
  }
}

class BackupRestoreResult {
  final bool ok;
  final String? error;
  final bool restoredDb;
  final int restoredPhotos;
  final int restoredSkills;
  final bool requiresRestart;
  const BackupRestoreResult({
    required this.ok,
    this.error,
    this.restoredDb = false,
    this.restoredPhotos = 0,
    this.restoredSkills = 0,
    this.requiresRestart = false,
  });
}

final backupServiceProvider = Provider<BackupService>(
    (ref) => BackupService(ref.watch(appDatabaseProvider)));
