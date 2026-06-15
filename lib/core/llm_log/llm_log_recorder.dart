import 'dart:async';

import 'llm_log_entry.dart';
import 'llm_log_repository.dart';

/// 帮助 LLM client 写日志的小工具：开始时构造，成功/失败时调对应方法。
///
/// 用法：
/// ```dart
/// final scope = LlmLogScope.start(repo, 'openai', model, reqSummary, rawReq);
/// try {
///   final r = await ...;
///   scope.success(summary: ..., rawResponse: ...);
///   return r;
/// } catch (e) {
///   scope.error(message: ..., statusCode: ...);
///   rethrow;
/// }
/// ```
class LlmLogScope {
  final LlmLogRepository? _repo;
  final String _channel;
  final String _model;
  final String _requestSummary;
  final String? _rawRequest;
  final DateTime _start;

  LlmLogScope._(
    this._repo,
    this._channel,
    this._model,
    this._requestSummary,
    this._rawRequest,
  ) : _start = DateTime.now();

  static LlmLogScope start(
    LlmLogRepository? repo, {
    required String channel,
    required String model,
    required String requestSummary,
    String? rawRequest,
  }) =>
      LlmLogScope._(repo, channel, model, requestSummary, rawRequest);

  int get _ms => DateTime.now().difference(_start).inMilliseconds;

  void success({
    required String responseSummary,
    int? statusCode,
    String? rawResponse,
  }) {
    final repo = _repo;
    if (repo == null) return;
    unawaited(repo.append(LlmLogEntry(
      timestamp: _start.millisecondsSinceEpoch,
      channel: _channel,
      model: _model,
      requestSummary: _truncate(_requestSummary, 200),
      responseSummary: _truncate(responseSummary, 200),
      durationMs: _ms,
      ok: true,
      statusCode: statusCode,
      rawRequest: _rawRequest,
      rawResponse: rawResponse,
    )));
  }

  void error({
    required String message,
    int? statusCode,
    String? rawResponse,
  }) {
    final repo = _repo;
    if (repo == null) return;
    unawaited(repo.append(LlmLogEntry(
      timestamp: _start.millisecondsSinceEpoch,
      channel: _channel,
      model: _model,
      requestSummary: _truncate(_requestSummary, 200),
      responseSummary: _truncate(message, 200),
      durationMs: _ms,
      ok: false,
      statusCode: statusCode,
      rawRequest: _rawRequest,
      rawResponse: rawResponse,
    )));
  }

  static String _truncate(String s, int n) =>
      s.length <= n ? s : '${s.substring(0, n)}…';
}
