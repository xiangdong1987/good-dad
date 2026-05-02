import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calendar/daily_task.dart';
import '../../core/calendar/schedule_extractor.dart';
import '../../core/memory/memory_extractor.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/skill/skill_runner.dart';
import '../../core/storage/database.dart';
import '../../core/storage/file_store.dart';

enum ChatBubbleRole { user, assistant, system }

class ChatBubble {
  final ChatBubbleRole role;
  final String text;
  final String? imagePath; // 用户消息可能带图（M2 暂未持久化图片）
  final bool streaming;
  const ChatBubble({
    required this.role,
    required this.text,
    this.imagePath,
    this.streaming = false,
  });

  ChatBubble copyWith({String? text, bool? streaming}) => ChatBubble(
        role: role,
        text: text ?? this.text,
        imagePath: imagePath,
        streaming: streaming ?? this.streaming,
      );
}

class ChatState {
  final List<ChatBubble> bubbles;
  final bool busy;
  final String? error;
  final int? sessionId;

  const ChatState({
    this.bubbles = const [],
    this.busy = false,
    this.error,
    this.sessionId,
  });

  ChatState copyWith({
    List<ChatBubble>? bubbles,
    bool? busy,
    String? error,
    int? sessionId,
    bool clearError = false,
  }) =>
      ChatState(
        bubbles: bubbles ?? this.bubbles,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
        sessionId: sessionId ?? this.sessionId,
      );
}

class ChatSessionController extends Notifier<ChatState> {
  // 注意：Riverpod 的 build() 会因为 watch 的依赖变化（如 profile / locale）重新执行，
  // 所以这里必须用普通字段（每次重写赋值），不能 late final。
  late AppDatabase _db;
  late SkillRunner? _runner;
  late FileStore _files;

  @override
  ChatState build() {
    _db = ref.watch(appDatabaseProvider);
    _runner = ref.watch(skillRunnerProvider);
    _files = ref.watch(fileStoreProvider);
    return const ChatState();
  }

  /// 用户发送一条消息（可能附带图片）。
  /// 内部：写库 user msg → 流式调 LLM → 边接边更新 → 完成后写库 assistant msg。
  Future<void> send({
    required String text,
    Uint8List? imageBytes,
    String skillName = 'chat',
  }) async {
    final input = text.trim();
    if (input.isEmpty && imageBytes == null) return;
    final runner = _runner;
    if (runner == null) {
      state = state.copyWith(error: '请先到「设置」配好 LLM');
      return;
    }

    final profile =
        ref.read(profileProvider).valueOrNull ?? FamilyProfile.empty;

    // 1. 创建会话（如果没有）
    final sessionId = state.sessionId ??
        await _db.into(_db.chatSessions).insert(
              ChatSessionsCompanion.insert(
                title: input.isEmpty ? '聊聊' : _firstLine(input, max: 24),
                skillName: Value(skillName),
              ),
            );

    // 2. 如果带了图片，先存盘以便聊天气泡引用
    String? userImagePath;
    if (imageBytes != null) {
      userImagePath = await _files.saveChatPhoto(imageBytes);
    }

    // 3. 写 user 气泡 + 落库
    final userBubble = ChatBubble(
      role: ChatBubbleRole.user,
      text: input,
      imagePath: userImagePath,
    );
    final assistantBubble = const ChatBubble(
      role: ChatBubbleRole.assistant,
      text: '',
      streaming: true,
    );
    state = state.copyWith(
      bubbles: [...state.bubbles, userBubble, assistantBubble],
      busy: true,
      sessionId: sessionId,
      clearError: true,
    );
    await _db.into(_db.messages).insert(
          MessagesCompanion.insert(
            sessionId: sessionId,
            role: 'user',
            content: input,
            imagePath: userImagePath == null
                ? const Value.absent()
                : Value(userImagePath),
          ),
        );

    // 3. 流式跑 skill
    final assistantIndex = state.bubbles.length - 1;
    String collected = '';
    try {
      final result = await runner.runStream(
        skillName,
        text: input,
        imageBytes: imageBytes,
        profile: profile,
        onChunk: (delta) {
          collected += delta;
          final updated = [...state.bubbles];
          updated[assistantIndex] =
              updated[assistantIndex].copyWith(text: collected);
          state = state.copyWith(bubbles: updated);
        },
      );
      // 4. 流结束，落 assistant msg
      final finalBubbles = [...state.bubbles];
      finalBubbles[assistantIndex] = finalBubbles[assistantIndex].copyWith(
        text: result.rawText,
        streaming: false,
      );
      state = state.copyWith(bubbles: finalBubbles, busy: false);
      await _db.into(_db.messages).insert(
            MessagesCompanion.insert(
              sessionId: sessionId,
              role: 'assistant',
              content: result.rawText,
              skillRunId: Value(result.skillRunId),
            ),
          );
      // 异步触发记忆抽取（失败不影响主对话）
      final extractor = ref.read(memoryExtractorProvider);
      if (extractor != null) {
        unawaited(extractor.extractFromTurn(
          userMessage: input,
          assistantMessage: result.rawText,
        ));
      }

      // 同步抽日程（很轻：纯本地解析，不调 LLM）
      final added = await ref
          .read(scheduleExtractorProvider)
          .extractAndPersist(result.rawText);
      if (added.isNotEmpty) {
        final summary = added.map(_summary).join(' · ');
        final updated = [
          ...state.bubbles,
          ChatBubble(
            role: ChatBubbleRole.system,
            text: '✅ 已加日历 · $summary',
          ),
        ];
        state = state.copyWith(bubbles: updated);
      }
    } on SkillRunError catch (e) {
      _markStreamFailure(assistantIndex, '出错了：${e.message}');
    } catch (e) {
      _markStreamFailure(assistantIndex, '出错了：$e');
    }
  }

  void _markStreamFailure(int idx, String msg) {
    final updated = [...state.bubbles];
    updated[idx] =
        updated[idx].copyWith(text: msg, streaming: false);
    state = state.copyWith(bubbles: updated, busy: false, error: msg);
  }

  void newSession() {
    state = const ChatState();
  }

  static String _firstLine(String text, {int max = 24}) {
    final l = text.split(RegExp(r'\r?\n')).first;
    return l.length <= max ? l : '${l.substring(0, max)}…';
  }

  static String _summary(DailyTask t) {
    final m = t.forDate.month.toString().padLeft(2, '0');
    final d = t.forDate.day.toString().padLeft(2, '0');
    return '$m/$d ${t.title}';
  }
}

final chatSessionControllerProvider =
    NotifierProvider<ChatSessionController, ChatState>(
        ChatSessionController.new);
