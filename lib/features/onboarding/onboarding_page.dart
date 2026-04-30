import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notification/weekly_notifier.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 首启引导：填爸爸称呼 + 妈妈称呼 + 当前孕周。
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _dadCtl = TextEditingController();
  final _momCtl = TextEditingController();
  final _weekCtl = TextEditingController();
  bool _saving = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _dadCtl.dispose();
    _momCtl.dispose();
    _weekCtl.dispose();
    super.dispose();
  }

  void _hydrate(FamilyProfile p) {
    if (_hydrated) return;
    _dadCtl.text = p.dadName ?? '';
    _momCtl.text = p.momName ?? '';
    final w = p.currentWeek();
    if (w != null) _weekCtl.text = w.toString();
    _hydrated = true;
  }

  Future<void> _submit() async {
    final dad = _dadCtl.text.trim();
    final mom = _momCtl.text.trim();
    final weekStr = _weekCtl.text.trim();
    final week = int.tryParse(weekStr);

    if (dad.isEmpty || mom.isEmpty || week == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('三项都得填好')),
      );
      return;
    }
    if (week < 1 || week > 42) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('孕周一般在 1–42 之间')),
      );
      return;
    }

    setState(() => _saving = true);
    final dueDate = FamilyProfile.dueDateFromCurrentWeek(week);
    await ref.read(profileProvider.notifier).save(
          FamilyProfile(dadName: dad, momName: mom, dueDate: dueDate),
        );
    // 第一次使用时申请通知权限并调度（profile complete 后 main 会再调一次，幂等）
    await WeeklyNotifier.requestPermissions();
    await WeeklyNotifier.scheduleAll();
    if (!mounted) return;
    setState(() => _saving = false);
    // HomePage 监听 profileProvider，会自动重建到主页
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('读取 profile 失败: $e')),
          data: (p) {
            _hydrate(p);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Center(
                  child: Sticker(
                    emoji: '👋',
                    background: AppColors.lemon300,
                    size: 56,
                    tilt: -6,
                  ),
                ),
                const SizedBox(height: 16),
                Text('先认识一下',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 6),
                const Text(
                  '让我知道这个家有谁、宝宝多大了，\n之后所有 AI 回答才会贴你们家的情况。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.ink600,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 28),

                _Field(
                  label: '我（爸爸）希望被叫',
                  hint: '老周 / 阿明 / 爸比',
                  emoji: '🐻',
                  controller: _dadCtl,
                ),
                const SizedBox(height: 14),
                _Field(
                  label: '老婆（妈妈）希望被叫',
                  hint: '小芸 / 阿姐 / 妈妈',
                  emoji: '🌷',
                  controller: _momCtl,
                ),
                const SizedBox(height: 14),
                _Field(
                  label: '宝宝现在第几周',
                  hint: '直接填数字，比如 24',
                  emoji: '👶',
                  controller: _weekCtl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
                const SizedBox(height: 8),
                CreamCard(
                  flat: true,
                  background: AppColors.cream200,
                  padding: const EdgeInsets.all(12),
                  child: Row(children: const [
                    Text('💡', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '不知道孕周？看产检本「孕XX周X天」那一栏，或者算一下：从最后一次月经第 1 天到今天，除以 7。',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          height: 1.55,
                          color: AppColors.ink600,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 28),

                CreamButton(
                  label: _saving ? '保存中…' : '走，进首页',
                  emoji: _saving ? null : '🚀',
                  onPressed: _saving ? null : _submit,
                  full: true,
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    '所有数据只存在你这部手机上 · 随时能改',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.ink400,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final String emoji;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.label,
    required this.hint,
    required this.emoji,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Sticker(
              emoji: emoji,
              size: 28,
              background: AppColors.peach200),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 14)),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
