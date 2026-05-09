import 'dart:typed_data';

/// 语音 agent 状态机。
enum VoiceStatus {
  idle,
  requestingPermission,
  recording,
  thinking,
  executing,
  synthesizing,
  speaking,
  error,
}

/// agent 总状态。
class VoiceState {
  final VoiceStatus status;
  final String? transcript;
  final String? speakText;
  final String? currentTool;
  final String? errorMessage;

  const VoiceState({
    this.status = VoiceStatus.idle,
    this.transcript,
    this.speakText,
    this.currentTool,
    this.errorMessage,
  });

  static const idle = VoiceState();

  VoiceState copyWith({
    VoiceStatus? status,
    String? transcript,
    String? speakText,
    String? currentTool,
    String? errorMessage,
    bool clearError = false,
    bool clearTranscript = false,
  }) =>
      VoiceState(
        status: status ?? this.status,
        transcript:
            clearTranscript ? null : (transcript ?? this.transcript),
        speakText: speakText ?? this.speakText,
        currentTool: currentTool ?? this.currentTool,
        errorMessage:
            clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// agent 调用工具时的参数 + 用于 TTS 的口播文案。
class AgentResponse {
  /// 模型识别到的工具名；null = 直接 chat 回答（speakText 即答案）。
  final String? toolName;
  final Map<String, dynamic> args;

  /// 给 TTS 念的话（不管走不走 tool 都会有）。
  final String speakText;

  /// 模型识别到的用户原话（如果厂商返回；可能为空）。
  final String? transcript;

  /// 模型直接返回的音频字节（小米 modalities: text+audio 时有）。
  /// 如果有，orchestrator 直接播放，跳过 TTS 调用。
  final Uint8List? audioBytes;
  final String audioMime;

  /// 原始模型 JSON，用于排错。
  final Map<String, dynamic>? raw;

  const AgentResponse({
    required this.speakText,
    this.toolName,
    this.args = const {},
    this.transcript,
    this.audioBytes,
    this.audioMime = 'audio/mpeg',
    this.raw,
  });
}

/// 工具执行结果。
class ToolResult {
  /// 用户可见的口播文案；为空则用 [AgentResponse.speakText] 回退。
  final String? speakText;

  /// 是否要弹「撤销」 SnackBar。
  final UndoSnack? undo;

  /// 是否提前停止 TTS（比如 navigate_to 之后想让用户立刻看新页面，不读太长）。
  final bool silent;

  const ToolResult({this.speakText, this.undo, this.silent = false});
}

class UndoSnack {
  final String label;
  final Future<void> Function() undo;
  final Duration window;

  const UndoSnack({
    required this.label,
    required this.undo,
    this.window = const Duration(seconds: 4),
  });
}

/// 当前页面给 agent 的上下文（如意大利驾照当前题目）。
class PageContext {
  /// 标识当前页面类型：'italian_license' / 'food_safety' / 'home' …
  final String kind;
  final Map<String, dynamic> payload;

  const PageContext({required this.kind, this.payload = const {}});
}

/// 录音结果。
class RecordedAudio {
  final Uint8List bytes;

  /// MIME 类型，例如 'audio/mpeg' / 'audio/wav' / 'audio/aac'。
  final String mimeType;

  /// 录制时长（毫秒，可选）。
  final int? durationMs;

  const RecordedAudio({
    required this.bytes,
    required this.mimeType,
    this.durationMs,
  });
}
