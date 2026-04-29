import 'types.dart';

abstract class LlmClient {
  /// Streams chunks of an assistant reply.
  Stream<LlmChunk> chat(
    List<LlmMessage> messages, {
    String? model,
    double? temperature,
    bool needsVision = false,
  });

  /// Convenience: collects the stream into a single result.
  Future<LlmResult> chatOnce(
    List<LlmMessage> messages, {
    String? model,
    double? temperature,
    bool needsVision = false,
  }) async {
    final buf = StringBuffer();
    await for (final chunk in chat(
      messages,
      model: model,
      temperature: temperature,
      needsVision: needsVision,
    )) {
      buf.write(chunk.deltaText);
    }
    return LlmResult(text: buf.toString(), model: model);
  }
}
