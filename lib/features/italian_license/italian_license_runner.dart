import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/profile/profile.dart';
import '../../core/skill/skill_output.dart';
import '../../core/skill/skill_runner.dart';
import '../../core/storage/file_store.dart';
import 'italian_license_models.dart';
import 'italian_license_prompt.dart';

class ItalianLicenseError implements Exception {
  final String message;
  const ItalianLicenseError(this.message);
  @override
  String toString() => message;
}

class ItalianLicenseRun {
  final ItalianLicenseResult result;
  final String imagePath;
  final int? skillRunId;
  const ItalianLicenseRun({
    required this.result,
    required this.imagePath,
    required this.skillRunId,
  });
}

class ItalianLicenseRunner {
  final SkillRunner runner;
  final FileStore fileStore;

  ItalianLicenseRunner({required this.runner, required this.fileStore});

  Future<ItalianLicenseRun> run({
    required Uint8List rawImageBytes,
    required FamilyProfile profile,
    String? userText,
  }) async {
    final compressed = ItalianLicensePrompt.compressImage(rawImageBytes);
    final imagePath = await fileStore.saveLicensePhoto(compressed);

    SkillRunResult res;
    try {
      res = await runner.run(
        'italian-license',
        text: userText,
        imageBytes: compressed,
        profile: profile,
      );
    } on SkillRunError catch (e) {
      throw ItalianLicenseError(e.message);
    }

    final parsed = ItalianLicensePrompt.parseModelOutput(res.rawText);
    return ItalianLicenseRun(
      result: parsed,
      imagePath: imagePath,
      skillRunId: res.skillRunId,
    );
  }
}

final italianLicenseRunnerProvider = Provider<ItalianLicenseRunner?>((ref) {
  final runner = ref.watch(skillRunnerProvider);
  if (runner == null) return null;
  return ItalianLicenseRunner(
    runner: runner,
    fileStore: ref.watch(fileStoreProvider),
  );
});
