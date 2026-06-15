import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/memory/memory_repository.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/screen_capture/screen_capture_service.dart';
import '../italian_license/italian_license_models.dart';
import '../italian_license/italian_license_runner.dart';
import '../italian_license/italian_license_vocab.dart';

/// 灵动岛运行状态（主 isolate 侧）。
enum IslandStatus { disabled, active, capturing, thinking, error }

@immutable
class IslandState {
  final bool enabled;
  final IslandStatus status;
  final String? error;

  const IslandState({
    required this.enabled,
    required this.status,
    this.error,
  });

  static const disabled =
      IslandState(enabled: false, status: IslandStatus.disabled);

  IslandState copyWith({bool? enabled, IslandStatus? status, String? error}) =>
      IslandState(
        enabled: enabled ?? this.enabled,
        status: status ?? this.status,
        error: error,
      );
}

/// 驾照灵动岛控制器。
///
/// 职责（全部跑在主 isolate，能拿到 LLM 配置 / DB / profile）：
/// - 开/关灵动岛：申请悬浮窗权限 + 录屏授权 + 起/停截屏前台服务 + 显隐 overlay
/// - 监听 overlay isolate 发来的「截屏」事件 → 截屏 → 复用 [ItalianLicenseRunner]
///   跑 italian-license skill → 把结构化结果回传给 overlay 渲染卡片
///
/// overlay UI 本身在独立 isolate（见 island_overlay.dart），两边用
/// [FlutterOverlayWindow.shareData] + [FlutterOverlayWindow.overlayListener]
/// 传 JSON 字符串通信。
class IslandController extends Notifier<IslandState> {
  static const _storage = FlutterSecureStorage();
  static const _enabledKey = 'license_island_enabled';

  // overlay → main 的可靠通道。
  // 不能用 flutter_overlay_window 的 shareData：它的 overlay→main 转发依赖一个静态
  // messenger，冷启动时会被 overlay 引擎 attach 覆盖，导致 overlay 发的消息回环到
  // overlay 自己、主 isolate 收不到（点「看这题」就没反应、✕ 也关不掉）。
  // 改用自建 MethodChannel：overlay 引擎 → native(MainActivity) → 转发到 main 引擎。
  // main → overlay 方向（loading/result/error/reset）仍用 shareData，那条是好的。
  static const _bridge = MethodChannel('good_dad/island_bridge');

  ScreenCaptureService get _capture => ref.read(screenCaptureServiceProvider);

  @override
  IslandState build() {
    // native 收到 overlay 的请求后，会 invoke 到这个 handler。
    _bridge.setMethodCallHandler(_onBridgeCall);
    ref.onDispose(() => _bridge.setMethodCallHandler(null));
    return IslandState.disabled;
  }

  Future<dynamic> _onBridgeCall(MethodCall call) async {
    debugPrint('[island/main] bridge call: ${call.method}');
    switch (call.method) {
      case 'requestCapture':
        unawaited(_handleCapture());
        break;
      case 'dismiss':
        // overlay 上点了「✕」：彻底关掉灵动岛。
        unawaited(disable());
        break;
      case 'saveVocab':
        // overlay 上点了某个生词 chip：存进单词表（memory 表，和驾照页同一套）。
        final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? const {};
        unawaited(_saveVocab(args));
        break;
    }
    return true;
  }

  /// 把单词收藏进 memory 表（slug 形如 vocab.it.<词>），存好后回 overlay 标记为已收藏。
  Future<void> _saveVocab(Map<String, dynamic> args) async {
    final it = (args['it'] ?? '').toString().trim();
    if (it.isEmpty) return;
    final v = LicenseVocab(
      it: it,
      zh: (args['zh'] ?? '').toString(),
      note: (args['note'] ?? '').toString(),
    );
    try {
      await ref.read(memoryRepositoryProvider).upsert(ItalianLicenseVocab.toEntry(v));
      await _send({'action': 'vocabSaved', 'it': it});
    } catch (e) {
      debugPrint('[island/main] saveVocab failed: $e');
    }
  }

  /// App 启动时调用：若上次开着灵动岛且悬浮窗权限仍在，重新挂起小岛。
  Future<void> restoreIfEnabled() async {
    final flag = await _storage.read(key: _enabledKey);
    if (flag != '1') return;
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (!granted) return;
    await _showBubble();
    state = const IslandState(enabled: true, status: IslandStatus.active);
    // 注意：录屏 projection 在进程重启后会丢，首次截屏时再按需重新授权。
  }

  Future<void> enable() async {
    // 1) 悬浮窗权限
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (!granted) {
      await FlutterOverlayWindow.requestPermission();
      final ok = await FlutterOverlayWindow.isPermissionGranted();
      if (!ok) {
        state = state.copyWith(
            enabled: false,
            status: IslandStatus.error,
            error: '需要「悬浮窗」权限才能让小岛浮在别的 App 上');
        return;
      }
    }
    // 2) 录屏授权（整场只授权一次，前台服务持有 projection）
    final proj = await _capture.requestProjection();
    if (!proj) {
      state = state.copyWith(
          enabled: false,
          status: IslandStatus.error,
          error: '需要「录屏 / 截屏」授权才能看题');
      return;
    }
    // 3) 显示小岛
    await _showBubble();
    await _storage.write(key: _enabledKey, value: '1');
    state = const IslandState(enabled: true, status: IslandStatus.active);
  }

  Future<void> disable() async {
    // 只在还活着时关：closeOverlay 在 isRunning=false 时原生不回调，会把 await 挂死。
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
    await _capture.stop();
    await _storage.write(key: _enabledKey, value: '0');
    state = IslandState.disabled;
  }

  Future<void> _showBubble() async {
    if (!await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: '驾照小岛',
        overlayContent: '点我看题',
        flag: OverlayFlag.defaultFlag,
        alignment: OverlayAlignment.centerRight,
        positionGravity: PositionGravity.auto,
        height: 150, // 逻辑像素；overlay 内部会按 bubble/卡片自行 resize
        width: 200,
      );
    }
    // flutter_overlay_window 复用缓存引擎：重开时 overlay 的 initState 不再跑，
    // 既不会复位成药丸也不会重设尺寸（于是大小错乱 / 停在上次的卡片态）。
    // 由主 isolate 主动发 reset，让 overlay 每次显示都回到正确的药丸态和尺寸。
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await _send({'action': 'reset'});
  }

  // ── 截屏 + 跑 skill ──────────────────────────────────────────────────

  Future<void> _handleCapture() async {
    try {
      debugPrint('[island/main] _handleCapture start');
      state = state.copyWith(status: IslandStatus.capturing);
      // overlay 收到点击后会先把自己画成透明再发 capture，这里再多等一帧确保透明帧落地，
      // 避免把小岛拍进截图。
      await Future<void>.delayed(const Duration(milliseconds: 120));

      final active = await _capture.isProjectionActive();
      debugPrint('[island/main] projectionActive=$active');
      if (!active) {
        final ok = await _capture.requestProjection();
        debugPrint('[island/main] requestProjection=$ok');
        if (!ok) {
          await _send({'action': 'error', 'message': '录屏授权失效了，重新开一下小岛'});
          state = state.copyWith(status: IslandStatus.active);
          return;
        }
      }

      debugPrint('[island/main] captureOnce…');
      final bytes = await _capture.captureOnce(quality: 90);
      debugPrint('[island/main] captured ${bytes.length} bytes');
      await _send({'action': 'loading'});
      state = state.copyWith(status: IslandStatus.thinking);

      final runner = ref.read(italianLicenseRunnerProvider);
      if (runner == null) {
        debugPrint('[island/main] runner == null (no LLM configured)');
        await _send({'action': 'error', 'message': '还没配置 AI 模型，去设置里填一下'});
        state = state.copyWith(status: IslandStatus.active);
        return;
      }
      final profile = ref.read(profileProvider).valueOrNull ?? FamilyProfile.empty;

      debugPrint('[island/main] runner.run…');
      final run = await runner.run(rawImageBytes: bytes, profile: profile);
      final resultJson = run.result.toJson();
      // 标注每个生词是否已在单词表里（历史），让 overlay 直接显示「已收藏」。
      await _annotateSavedVocab(resultJson);
      debugPrint('[island/main] run done, answer=${resultJson['answer']}');
      await _send({'action': 'result', 'data': resultJson});
      state = state.copyWith(status: IslandStatus.active);
    } on ItalianLicenseError catch (e) {
      debugPrint('[island/main] ItalianLicenseError: ${e.message}');
      await _send({'action': 'error', 'message': e.message});
      state = state.copyWith(status: IslandStatus.active);
    } catch (e, st) {
      debugPrint('[island/main] capture error: $e\n$st');
      await _send({'action': 'error', 'message': '出错了：$e'});
      state = state.copyWith(status: IslandStatus.active);
    }
  }

  /// 给 result JSON 里的每个 vocabulary 条目加 `saved` 标记（是否已在单词表）。
  Future<void> _annotateSavedVocab(Map<String, dynamic> resultJson) async {
    final vocab = (resultJson['vocabulary'] as List?) ?? const [];
    if (vocab.isEmpty) return;
    try {
      final rows = await ref
          .read(memoryRepositoryProvider)
          .findActiveLikeNames([ItalianLicenseVocab.namePattern]);
      final savedSlugs = rows.map((e) => e.name).toSet();
      for (final v in vocab) {
        if (v is Map) {
          final slug = ItalianLicenseVocab.slugFor(
            LicenseVocab(it: (v['it'] ?? '').toString(), zh: '', note: ''),
          );
          v['saved'] = savedSlugs.contains(slug);
        }
      }
    } catch (e) {
      debugPrint('[island/main] annotate saved vocab failed: $e');
    }
  }

  Future<void> _send(Map<String, dynamic> data) async {
    await FlutterOverlayWindow.shareData(jsonEncode(data));
  }
}

final islandControllerProvider =
    NotifierProvider<IslandController, IslandState>(IslandController.new);
