/// 一条 LLM 调用日志：请求 + 响应（或错误）+ 耗时。
class LlmLogEntry {
  /// epoch ms。
  final int timestamp;

  /// 'mimo-agent' / 'mimo-tts' / 'openai'
  final String channel;

  /// 用的模型 id。
  final String model;

  /// 请求摘要：通常是最后一条 user message 或关键参数（截 200 字）。
  final String requestSummary;

  /// 响应摘要：拿到的 content / 字节数 / 错误信息（截 200 字）。
  final String responseSummary;

  /// 总耗时（毫秒）。错误也填，方便看超时分布。
  final int durationMs;

  /// 是否成功。
  final bool ok;

  /// 失败时的状态码，没拿到 HTTP 时为 null。
  final int? statusCode;

  /// 完整 request body（JSON 文本，audio bytes 已剥掉）；可能为 null。
  final String? rawRequest;

  /// 完整 response body（JSON 文本或错误正文）；可能为 null。
  final String? rawResponse;

  const LlmLogEntry({
    required this.timestamp,
    required this.channel,
    required this.model,
    required this.requestSummary,
    required this.responseSummary,
    required this.durationMs,
    required this.ok,
    this.statusCode,
    this.rawRequest,
    this.rawResponse,
  });

  Map<String, dynamic> toJson() => {
        't': timestamp,
        'c': channel,
        'm': model,
        'rq': requestSummary,
        'rs': responseSummary,
        'd': durationMs,
        'ok': ok,
        if (statusCode != null) 'sc': statusCode,
        if (rawRequest != null) 'rr_q': rawRequest,
        if (rawResponse != null) 'rr_s': rawResponse,
      };

  factory LlmLogEntry.fromJson(Map<String, dynamic> j) => LlmLogEntry(
        timestamp: (j['t'] as num).toInt(),
        channel: j['c'] as String,
        model: j['m'] as String,
        requestSummary: j['rq'] as String? ?? '',
        responseSummary: j['rs'] as String? ?? '',
        durationMs: (j['d'] as num?)?.toInt() ?? 0,
        ok: j['ok'] as bool? ?? false,
        statusCode: (j['sc'] as num?)?.toInt(),
        rawRequest: j['rr_q'] as String?,
        rawResponse: j['rr_s'] as String?,
      );

  DateTime get time => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
