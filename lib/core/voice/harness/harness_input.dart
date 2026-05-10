import 'dart:typed_data';

import '../voice_types.dart';

/// 一个 Turn 的输入。三个具体形态：voice / text / text+image。
///
/// 用 sealed class 让 reasoner / orchestrator 在 switch 里穷举处理。
/// 后续要加 video / file 之类只要新加子类。
sealed class HarnessInput {
  const HarnessInput();
}

class VoiceHarnessInput extends HarnessInput {
  final RecordedAudio audio;
  const VoiceHarnessInput(this.audio);

  @override
  String toString() =>
      'VoiceHarnessInput(${audio.bytes.length}B ${audio.mimeType})';
}

class TextHarnessInput extends HarnessInput {
  final String text;

  /// 单张可选图片；想支持多张图片 v2 改成 `List<Uint8List>`。
  final Uint8List? image;

  const TextHarnessInput({required this.text, this.image});

  bool get hasImage => image != null && image!.isNotEmpty;

  @override
  String toString() =>
      'TextHarnessInput(text=${text.length}c image=${hasImage ? "${image!.length}B" : "no"})';
}
