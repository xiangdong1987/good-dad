import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/notification/weekly_notifier.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 编辑家庭信息（爸爸 / 妈妈称呼 + 当前孕周）。
/// onboarding 是首次必填；这页可随时进来改。
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _dadCtl = TextEditingController();
  final _momCtl = TextEditingController();
  final _weekCtl = TextEditingController();
  bool _hydrated = false;
  bool _saving = false;

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

  Future<void> _save() async {
    final dad = _dadCtl.text.trim();
    final mom = _momCtl.text.trim();
    final week = int.tryParse(_weekCtl.text.trim());

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
    // 孕周改了，把通知重建一次（如果之前未授权也顺手再申请一次）
    await WeeklyNotifier.requestPermissions();
    await WeeklyNotifier.scheduleAll();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已更新 · 所有 skill 自动跟着变')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('家庭信息'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('读取失败: $e')),
        data: (p) {
          _hydrate(p);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const Text(
                '改完保存，所有 skill（食物识别、食谱、聊天）会自动用新孕周和称呼。',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.55,
                    color: AppColors.ink600),
              ),
              const SizedBox(height: 16),
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
                label: '当前孕周',
                hint: '比如 24',
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
                      '今天填多少周，明天就自动变成多少周。预产期由「今天 + (40-当前周)*7」算出来。',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          height: 1.55,
                          color: AppColors.ink600),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              CreamButton(
                label: _saving ? '保存中…' : '保存',
                emoji: _saving ? null : '💾',
                onPressed: _saving ? null : _save,
                full: true,
              ),
            ],
          );
        },
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
