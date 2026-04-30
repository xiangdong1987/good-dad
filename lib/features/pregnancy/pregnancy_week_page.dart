import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/pregnancy/weekly_brief.dart';
import '../../core/pregnancy/weekly_brief_repository.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 本周孕期 · Pregnancy Week
///
/// PageView 横向滑动，1-42 周每周一页。
/// 每页 cache-first：有缓存直接渲染，没有就 CTA「生成本周建议」调 LLM。
class PregnancyWeekPage extends ConsumerStatefulWidget {
  const PregnancyWeekPage({super.key});
  @override
  ConsumerState<PregnancyWeekPage> createState() =>
      _PregnancyWeekPageState();
}

class _PregnancyWeekPageState extends ConsumerState<PregnancyWeekPage> {
  static const _totalWeeks = 42;
  late final PageController _ctrl;
  int _displayedWeek = 24;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).valueOrNull;
    final initial = (profile?.currentWeek() ?? 24).clamp(1, _totalWeeks);
    _displayedWeek = initial;
    _ctrl = PageController(initialPage: initial - 1);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// 简陋的孕周→大小类比兜底（skill 已生成时优先用 skill 的 baby_size）
  static String _sizeAnalogy(int week) {
    if (week <= 4) return '罂粟籽 ✨';
    if (week <= 6) return '小扁豆 🫛';
    if (week <= 8) return '葡萄 🍇';
    if (week <= 10) return '草莓 🍓';
    if (week <= 12) return '青柠 🍋‍🟩';
    if (week <= 14) return '柠檬 🍋';
    if (week <= 16) return '苹果 🍎';
    if (week <= 18) return '青椒 🫑';
    if (week <= 20) return '香蕉 🍌';
    if (week <= 22) return '木瓜 🥭';
    if (week <= 24) return '玉米 🌽';
    if (week <= 26) return '甜瓜 🍈';
    if (week <= 28) return '茄子 🍆';
    if (week <= 30) return '卷心菜 🥬';
    if (week <= 32) return '椰子 🥥';
    if (week <= 34) return '哈密瓜 🍈';
    if (week <= 36) return '生菜 🥬';
    if (week <= 38) return '冬瓜 🍉';
    return '小西瓜 🍉';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text('第 $_displayedWeek 周'),
        actions: [
          IconButton(
              tooltip: '日历',
              icon: const Icon(Icons.calendar_month_rounded),
              onPressed: () => context.push('/calendar')),
        ],
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: _totalWeeks,
        onPageChanged: (i) => setState(() => _displayedWeek = i + 1),
        itemBuilder: (_, i) => _WeekPage(
          week: i + 1,
          sizeAnalogy: _sizeAnalogy(i + 1),
        ),
      ),
    );
  }
}

class _WeekPage extends ConsumerWidget {
  final int week;
  final String sizeAnalogy;
  const _WeekPage({required this.week, required this.sizeAnalogy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBrief = ref.watch(weeklyBriefProvider(week));
    final profile =
        ref.watch(profileProvider).valueOrNull ?? FamilyProfile.empty;
    final realCurrent = profile.currentWeek();
    final isCurrent = realCurrent == week;
    final remaining = (40 - week).clamp(0, 40);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // 大数字
        Center(
          child: Column(children: [
            Text(
              isCurrent ? '本周 · 还有 $remaining 周' : '第 $week 周',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: AppColors.ink600),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 90,
                    height: 1,
                    color: AppColors.peach700,
                    letterSpacing: -3),
                children: [
                  TextSpan(text: '$week'),
                  const TextSpan(
                      text: 'w',
                      style: TextStyle(fontSize: 32, color: AppColors.ink400)),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // 内容区：cache-first
        asyncBrief.when(
          loading: () => const _LoadingPlaceholder(),
          error: (e, _) => _ErrorView(
              error: '$e',
              week: week),
          data: (brief) => brief == null
              ? _NotGeneratedYet(week: week, sizeAnalogy: sizeAnalogy)
              : _BriefBody(brief: brief, fallbackSize: sizeAnalogy),
        ),
      ],
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator()));
}

class _NotGeneratedYet extends ConsumerStatefulWidget {
  final int week;
  final String sizeAnalogy;
  const _NotGeneratedYet({required this.week, required this.sizeAnalogy});

  @override
  ConsumerState<_NotGeneratedYet> createState() => _NotGeneratedYetState();
}

class _NotGeneratedYetState extends ConsumerState<_NotGeneratedYet> {
  bool _busy = false;
  String? _error;

  Future<void> _go() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(weeklyBriefRepositoryProvider)
          .generate(widget.week);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 占位卡 (类比大小)
        CreamCard(
          background: AppColors.sky300,
          padding: const EdgeInsets.all(20),
          child: Stack(children: [
            const Positioned(
              top: 0,
              right: 0,
              child: Sticker(
                  emoji: '✨',
                  background: AppColors.lemon300,
                  size: 36,
                  tilt: 6),
            ),
            Center(
              child: Column(children: [
                const Text('👶',
                    style: TextStyle(fontSize: 96, height: 1)),
                const SizedBox(height: 8),
                Text('大概像${widget.sizeAnalogy}',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.ink700)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        CreamCard(
          background: AppColors.cream200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '这一周还没生成详细建议',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'AI 会根据你的家庭信息生成宝宝发育要点 / 营养 / 该做什么 / 爸爸能帮的事，结果会缓存下来。',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.55,
                    color: AppColors.ink700),
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Text(_error!,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.peach700)),
                const SizedBox(height: 8),
              ],
              CreamButton(
                label: _busy ? '生成中…' : '让 AI 给我生成',
                emoji: _busy ? null : '✨',
                onPressed: _busy ? null : _go,
                full: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final int week;
  const _ErrorView({required this.error, required this.week});
  @override
  Widget build(BuildContext context) => CreamCard(
        background: AppColors.rose300,
        padding: const EdgeInsets.all(14),
        child: Text('第 $week 周加载失败: $error',
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      );
}

class _BriefBody extends ConsumerWidget {
  final WeeklyBrief brief;
  final String fallbackSize;
  const _BriefBody({required this.brief, required this.fallbackSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = brief.data;
    final size = (d?.babySize.isNotEmpty ?? false) ? d!.babySize : fallbackSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 类比大小卡
        CreamCard(
          background: AppColors.sky300,
          padding: const EdgeInsets.all(20),
          child: Stack(children: [
            const Positioned(
              top: 0,
              right: 0,
              child: Sticker(
                  emoji: '✨',
                  background: AppColors.lemon300,
                  size: 36,
                  tilt: 6),
            ),
            Center(
              child: Column(children: [
                const Text('👶',
                    style: TextStyle(fontSize: 96, height: 1)),
                const SizedBox(height: 8),
                Text('大概像$size',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.ink700)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        if (d == null) ...[
          // 解析 JSON 失败但有 raw text — 兜底
          CreamCard(
            background: AppColors.lemon300,
            padding: const EdgeInsets.all(14),
            child: const Text(
              '模型这次没遵守 JSON 格式，下面是它的原文：',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          CreamCard(
            flat: true,
            padding: const EdgeInsets.all(14),
            child: Text(brief.rawText,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.ink700)),
          ),
        ] else ...[
          if (d.babyDev.isNotEmpty)
            _Section(
                title: '宝宝在干嘛',
                emoji: '👶',
                bg: AppColors.peach200,
                child: Text(d.babyDev,
                    style: _bodyStyle())),
          if (d.momChanges.isNotEmpty)
            _Section(
                title: '妈妈这周',
                emoji: '🌷',
                bg: AppColors.rose300,
                child: Text(d.momChanges, style: _bodyStyle())),
          if (d.husbandCanDo.isNotEmpty)
            _Section(
                title: '爸爸可以做的',
                emoji: '💪',
                bg: AppColors.lemon300,
                child: _BulletList(items: d.husbandCanDo)),
          if (d.nutrition.isNotEmpty)
            _Section(
                title: '吃什么好',
                emoji: '🍲',
                bg: AppColors.mint300,
                child: _BulletList(items: d.nutrition)),
          if (d.todos.isNotEmpty)
            _Section(
                title: '本周待办',
                emoji: '📝',
                bg: AppColors.cream200,
                child: _BulletList(items: d.todos)),
          if (d.warnings.isNotEmpty)
            _Section(
                title: '注意信号',
                emoji: '⚠',
                bg: AppColors.rose300,
                child: _BulletList(items: d.warnings)),
        ],
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () async {
              await ref
                  .read(weeklyBriefRepositoryProvider)
                  .generate(brief.week);
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('重新生成'),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '以上为参考，最终请以产检医生 / 营养师为准。',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.ink400),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _bodyStyle() => const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w700,
        fontSize: 13,
        height: 1.55,
        color: AppColors.ink900,
      );
}

class _Section extends StatelessWidget {
  final String title;
  final String emoji;
  final Color bg;
  final Widget child;
  const _Section(
      {required this.title,
      required this.emoji,
      required this.bg,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CreamCard(
        flat: true,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Sticker(emoji: emoji, background: bg, size: 28),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 14)),
            ]),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('· $s',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.ink700)),
          ),
      ],
    );
  }
}
