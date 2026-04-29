import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// File storage helper. Lays out user-generated content under app documents:
///
/// ```
/// <docs>/
///   photos/food/        # food-safety captures
///   photos/belly/       # belly-photo timeline
///   skills/             # user-imported SKILL.md packages
/// ```
class FileStore {
  static const _uuid = Uuid();

  Future<Directory> _ensure(String relative) async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, relative));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> saveFoodPhoto(Uint8List bytes,
      {String extension = 'jpg'}) async {
    final dir = await _ensure(p.join('photos', 'food'));
    final file = File(p.join(dir.path, '${_uuid.v4()}.$extension'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<String> saveBellyPhoto(Uint8List bytes,
      {String extension = 'jpg'}) async {
    final dir = await _ensure(p.join('photos', 'belly'));
    final file = File(p.join(dir.path, '${_uuid.v4()}.$extension'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<Directory> userSkillsDir() => _ensure('skills');
}

final fileStoreProvider = Provider<FileStore>((ref) => FileStore());
