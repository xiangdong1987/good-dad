import 'dart:convert';
import 'dart:typed_data';

enum LlmRole { system, user, assistant, tool }

sealed class MessagePart {
  const MessagePart();
}

class TextPart extends MessagePart {
  final String text;
  const TextPart(this.text);
}

class ImagePart extends MessagePart {
  /// JPEG/PNG bytes; encoded to data URL on the wire.
  final Uint8List bytes;
  final String mimeType; // e.g. image/jpeg
  const ImagePart(this.bytes, {this.mimeType = 'image/jpeg'});

  String toDataUrl() => 'data:$mimeType;base64,${base64Encode(bytes)}';
}

class LlmMessage {
  final LlmRole role;
  final List<MessagePart> parts;

  const LlmMessage(this.role, this.parts);

  factory LlmMessage.system(String text) =>
      LlmMessage(LlmRole.system, [TextPart(text)]);
  factory LlmMessage.user(String text) =>
      LlmMessage(LlmRole.user, [TextPart(text)]);
  factory LlmMessage.assistant(String text) =>
      LlmMessage(LlmRole.assistant, [TextPart(text)]);

  bool get hasImage => parts.any((p) => p is ImagePart);
  String get textContent =>
      parts.whereType<TextPart>().map((p) => p.text).join('\n');
}

class LlmChunk {
  final String deltaText;
  final bool done;
  const LlmChunk(this.deltaText, {this.done = false});
}

class LlmResult {
  final String text;
  final int? promptTokens;
  final int? completionTokens;
  final String? model;

  const LlmResult({
    required this.text,
    this.promptTokens,
    this.completionTokens,
    this.model,
  });
}

class LlmException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;
  const LlmException(this.message, {this.statusCode, this.cause});

  @override
  String toString() =>
      'LlmException(${statusCode ?? '-'}): $message${cause == null ? '' : ' / $cause'}';
}
