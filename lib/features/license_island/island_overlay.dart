import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// overlay → main 的桥（见 island_controller.dart 里同名 channel 的说明）。
/// 不用 shareData，因为它的 overlay→main 方向被 flutter_overlay_window 的
/// messenger-覆盖 bug 弄成了自我回环。
const _islandBridge = MethodChannel('good_dad/island_bridge');

/// flutter_overlay_window 的 overlay UI 根。
///
/// 跑在**独立 isolate**（无 Riverpod / DB / LLM）。只负责画 UI + 跟主 isolate
/// 用 [FlutterOverlayWindow.shareData] / [FlutterOverlayWindow.overlayListener]
/// 通信。截屏 + 跑 skill 都在主 isolate（见 island_controller.dart）。
///
/// overlay 的入口函数 `overlayMain` 定义在 lib/main.dart（包按该名在根库查找），
/// 它会 runApp 本 widget。
class IslandOverlayApp extends StatelessWidget {
  const IslandOverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      theme: AppTheme.light(),
      home: const Scaffold(
        backgroundColor: Colors.transparent,
        body: _IslandRoot(),
      ),
    );
  }
}

enum _Mode { bubble, hidden, loading, result, error }

// overlay 窗口在不同形态下的尺寸（逻辑像素，可按机型微调）。
const _bubbleW = 178, _bubbleH = 60;
const _loadingW = 200, _loadingH = 68;
const _cardW = 376, _cardH = 710;

class _IslandRoot extends StatefulWidget {
  const _IslandRoot();

  @override
  State<_IslandRoot> createState() => _IslandRootState();
}

class _IslandRootState extends State<_IslandRoot> {
  _Mode _mode = _Mode.bubble;
  Map<String, dynamic>? _result;
  String _errorMsg = '';
  // 本次结果里已收藏到单词表的词（按意大利语原词 it 去重）。
  Set<String> _savedWords = const {};

  // 点了「看题」后小岛会先缩成 1x1 隐藏，等主 isolate 回 loading/result/error。
  // 万一主 isolate 没回（没配模型、截屏挂了等），这个看门狗把小岛恢复成药丸，
  // 避免卡在隐藏态——表现就是「点了没反应、也取消不了」。
  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    debugPrint('[island/ovl] initState — listening');
    FlutterOverlayWindow.overlayListener.listen(_onMessage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterOverlayWindow.resizeOverlay(_bubbleW, _bubbleH, true);
    });
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    super.dispose();
  }

  void _onMessage(dynamic raw) {
    final msg = _decode(raw);
    if (msg == null) return;
    debugPrint('[island/ovl] got msg: ${msg['action']}');
    _watchdog?.cancel(); // 收到任何回复都说明主 isolate 还活着
    switch (msg['action']) {
      case 'reset':
        // 主 isolate 在（重新）显示小岛时发来：缓存引擎复用导致 initState 不再跑，
        // 这里强制复位成药丸 + 重设尺寸，修复重开后大小错乱 / 停在旧卡片态。
        setState(() {
          _mode = _Mode.bubble;
          _result = null;
          _errorMsg = '';
        });
        FlutterOverlayWindow.resizeOverlay(_bubbleW, _bubbleH, true);
        break;
      case 'loading':
        setState(() => _mode = _Mode.loading);
        FlutterOverlayWindow.resizeOverlay(_loadingW, _loadingH, false);
        break;
      case 'result':
        final data = (msg['data'] as Map).cast<String, dynamic>();
        final vocab = (data['vocabulary'] as List?) ?? const [];
        final saved = <String>{
          for (final v in vocab.whereType<Map>())
            if (v['saved'] == true) (v['it'] ?? '').toString(),
        }..remove('');
        setState(() {
          _result = data;
          _savedWords = saved;
          _mode = _Mode.result;
        });
        FlutterOverlayWindow.resizeOverlay(_cardW, _cardH, false);
        // 卡片较高：把窗口重新垂直居中，否则顶部会被推出屏幕（小岛被拖动/默认偏移导致）。
        FlutterOverlayWindow.moveOverlay(const OverlayPosition(0, 0));
        break;
      case 'error':
        setState(() {
          _errorMsg = (msg['message'] ?? '出错了').toString();
          _mode = _Mode.error;
        });
        FlutterOverlayWindow.resizeOverlay(_cardW, 220, false);
        FlutterOverlayWindow.moveOverlay(const OverlayPosition(0, 0));
        break;
      case 'vocabSaved':
        // 主 isolate 存好单词后回执：把这个词标记为已收藏。
        final it = (msg['it'] ?? '').toString();
        if (it.isNotEmpty) {
          setState(() => _savedWords = {..._savedWords, it});
        }
        break;
    }
  }

  /// 点某个生词 chip：通知主 isolate 存进单词表（乐观先标已收藏）。
  Future<void> _saveWord(String it, String zh, String note) async {
    if (it.isEmpty || _savedWords.contains(it)) return;
    setState(() => _savedWords = {..._savedWords, it});
    await _islandBridge.invokeMethod('saveVocab', {'it': it, 'zh': zh, 'note': note});
  }

  /// 点击「看题 / 再看一题」：先把自己画成透明（不入镜），再通知主 isolate 截屏。
  ///
  /// 注意：**不要把窗口 resize 到 1×1** 来隐藏——退化尺寸会在部分机型（尤其华为）
  /// 把 overlay 的 EGL 渲染表面搞坏（logcat: "EGLNativeWindowType disconnect failed"），
  /// 之后 resize 回来也画不出东西，表现成「点一下就没了、再也回不来」。
  /// 改成保持药丸尺寸、内容渲染成透明的 SizedBox.shrink：MediaProjection 截的是
  /// 合成画面，透明区域就是底下 App，小岛照样不会进截图。
  Future<void> _requestCapture() async {
    debugPrint('[island/ovl] tap 看这题 — hide + send capture');
    setState(() => _mode = _Mode.hidden);
    await FlutterOverlayWindow.resizeOverlay(_bubbleW, _bubbleH, false);
    // 等透明帧渲染落地后再发，避免小岛入镜
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await _islandBridge.invokeMethod('requestCapture');
    // 8s 内没等到任何回复就自我恢复，别永远隐身。
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 8), () {
      if (mounted && _mode == _Mode.hidden) _collapse();
    });
  }

  /// 点击「✕」：通知主 isolate 关掉灵动岛（关录屏 + 收悬浮窗 + 落库）。
  Future<void> _dismiss() async {
    _watchdog?.cancel();
    await _islandBridge.invokeMethod('dismiss');
  }

  Future<void> _collapse() async {
    _watchdog?.cancel();
    setState(() {
      _mode = _Mode.bubble;
      _result = null;
    });
    await FlutterOverlayWindow.resizeOverlay(_bubbleW, _bubbleH, true);
  }

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case _Mode.hidden:
        return const SizedBox.shrink();
      case _Mode.bubble:
        return _Bubble(onTap: _requestCapture, onDismiss: _dismiss);
      case _Mode.loading:
        return const _LoadingPill();
      case _Mode.error:
        return _ErrorCard(message: _errorMsg, onClose: _collapse);
      case _Mode.result:
        return _ResultCard(
          data: _result ?? const <String, dynamic>{},
          savedWords: _savedWords,
          onSaveWord: _saveWord,
          onAgain: _requestCapture,
          onClose: _collapse,
        );
    }
  }

  Map<String, dynamic>? _decode(dynamic raw) {
    try {
      if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
      if (raw is Map) return raw.cast<String, dynamic>();
    } catch (_) {}
    return null;
  }
}

// ── 收起态：药丸 ────────────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _Bubble({required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 关闭按钮：随时撤掉小岛（通知主 isolate 关录屏 + 收悬浮窗）
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.rose500,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink900, width: 2),
                boxShadow: AppShadows.pop(false),
              ),
              child: const Text('✕',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
              decoration: BoxDecoration(
                color: AppColors.cream100,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.ink900, width: 2),
                boxShadow: AppShadows.pop(false),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Sticker(emoji: '🚗', size: 34, background: AppColors.peach300),
                  SizedBox(width: 8),
                  Text('看这题',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: AppColors.ink900)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 截屏 / 思考中 ──────────────────────────────────────────────────────
class _LoadingPill extends StatelessWidget {
  const _LoadingPill();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.lemon500,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.ink900, width: 2),
          boxShadow: AppShadows.pop(false),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.ink900),
            ),
            SizedBox(width: 10),
            Text('看题中…',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.ink900)),
          ],
        ),
      ),
    );
  }
}

// ── 错误小卡 ────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  const _ErrorCard({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CreamCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [
              Sticker(emoji: '😅', size: 34, background: AppColors.rose300),
              SizedBox(width: 10),
              Text('没看成',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
            ]),
            const SizedBox(height: 10),
            Text(message,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.ink700)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: CreamButton(label: '收起', emoji: '✕', onPressed: onClose),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 结果小卡片 ──────────────────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Set<String> savedWords;
  final Future<void> Function(String it, String zh, String note) onSaveWord;
  final VoidCallback onAgain;
  final VoidCallback onClose;
  const _ResultCard({
    required this.data,
    required this.savedWords,
    required this.onSaveWord,
    required this.onAgain,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final answer = (data['answer'] ?? '').toString().trim().toUpperCase();
    final format = (data['format'] ?? '').toString();
    final qit = (data['question_it'] ?? '').toString();
    final qzh = (data['question_zh'] ?? '').toString();
    final expl = (data['explanation_zh'] ?? '').toString();
    final mnemonic = (data['mnemonic'] ?? '').toString();
    final options = (data['options'] as List?) ?? const [];
    final vocab = (data['vocabulary'] as List?) ?? const [];
    final grammar = (data['grammar_notes'] as List?) ?? const [];

    final isUnknown = format == 'unknown' || answer.isEmpty;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: CreamCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.ink400,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _answerRow(answer, format, isUnknown),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (qit.isNotEmpty)
                      Text(qit,
                          style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.ink600)),
                    if (qzh.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(qzh,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              height: 1.45)),
                    ],
                    if (options.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...options.whereType<Map>().map((o) => _optionRow(
                            (o['letter'] ?? '').toString(),
                            (o['it'] ?? '').toString(),
                            (o['zh'] ?? '').toString(),
                            answer,
                          )),
                    ],
                    if (expl.isNotEmpty)
                      _section('💡 讲解', Text(expl,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              height: 1.5))),
                    if (vocab.isNotEmpty)
                      _section(
                          '📚 词汇（点一下收藏到单词表）',
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: vocab
                                .whereType<Map>()
                                .map((v) => _VocabChip(
                                      it: (v['it'] ?? '').toString(),
                                      zh: (v['zh'] ?? '').toString(),
                                      note: (v['note'] ?? '').toString(),
                                      saved: savedWords
                                          .contains((v['it'] ?? '').toString()),
                                      onSave: onSaveWord,
                                    ))
                                .toList(),
                          )),
                    if (grammar.isNotEmpty)
                      _section(
                          '✍️ 语法',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: grammar
                                .map((g) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 3),
                                      child: Text('· $g',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12.5,
                                              height: 1.45)),
                                    ))
                                .toList(),
                          )),
                    if (mnemonic.isNotEmpty)
                      _section('🧠 口诀', Text(mnemonic,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              height: 1.45))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CreamButton(
                      label: '再看一题',
                      emoji: '📸',
                      full: true,
                      onPressed: onAgain),
                ),
                const SizedBox(width: 8),
                CreamButton(label: '收起', ghost: true, onPressed: onClose),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerRow(String answer, String format, bool isUnknown) {
    late Color bg;
    late Color fg;
    late String text;
    late String label;
    if (isUnknown) {
      bg = AppColors.lemon500;
      fg = AppColors.ink900;
      text = '?';
      label = '没太看清这题';
    } else if (answer == 'V' || answer == 'VERO' || answer == 'TRUE') {
      bg = AppColors.mint500;
      fg = AppColors.ink900;
      text = 'V';
      label = '正确答案 · 判断题 → VERO（对）';
    } else if (answer == 'F' || answer == 'FALSO' || answer == 'FALSE') {
      bg = AppColors.rose500;
      fg = Colors.white;
      text = 'F';
      label = '正确答案 · 判断题 → FALSO（错）';
    } else {
      bg = AppColors.peach500;
      fg = AppColors.ink900;
      text = answer;
      label = '正确答案 · 选 $answer';
    }
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.ink900, width: 2),
            boxShadow: AppShadows.pop(false),
          ),
          child: Text(text,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: fg)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.ink900)),
        ),
      ],
    );
  }

  Widget _optionRow(String letter, String it, String zh, String answer) {
    final correct = letter.toUpperCase() == answer;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: correct ? AppColors.mint300 : AppColors.cream50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.ink900, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$letter. ',
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 13)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12.5)),
                if (zh.isNotEmpty)
                  Text(zh,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          color: AppColors.ink600)),
              ],
            ),
          ),
          if (correct)
            const Text('✓',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.mint700)),
        ],
      ),
    );
  }

  Widget _section(String title, Widget body) {
    return Container(
      margin: const EdgeInsets.only(top: 9),
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cream50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.ink900, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.4,
                  color: AppColors.peach700)),
          const SizedBox(height: 4),
          body,
        ],
      ),
    );
  }
}

// ── 可点收藏的生词 chip ──────────────────────────────────────────────────
class _VocabChip extends StatelessWidget {
  final String it;
  final String zh;
  final String note;
  final bool saved;
  final Future<void> Function(String it, String zh, String note) onSave;
  const _VocabChip({
    required this.it,
    required this.zh,
    required this.note,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: saved ? null : () => onSave(it, zh, note),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          // 已收藏 = mint 实底 + ✓；未收藏 = peach + ＋，提示可点。
          color: saved ? AppColors.mint300 : AppColors.peach200,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.ink900, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(saved ? '✓ ' : '＋ ',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: saved ? AppColors.mint700 : AppColors.peach700)),
            Flexible(
              child: Text(
                zh.isEmpty ? it : '$it  $zh',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppColors.ink900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
