import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/notification/daily_plan_notifier.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'fitness_models.dart';
import 'fitness_repository.dart';

/// 健身资料引导/编辑。保存后顺手登记每晚提醒。
class FitnessProfilePage extends ConsumerStatefulWidget {
  const FitnessProfilePage({super.key});

  @override
  ConsumerState<FitnessProfilePage> createState() =>
      _FitnessProfilePageState();
}

class _FitnessProfilePageState extends ConsumerState<FitnessProfilePage> {
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _age = TextEditingController();
  final _injuries = TextEditingController();
  Sex _sex = Sex.male;
  Experience _exp = Experience.novice;
  Goal _goal = Goal.maintain;
  int _minutes = 20;
  final Set<int> _kbs = {};
  bool _loaded = false;
  bool _saving = false;

  static const _kbOptions = [8, 12, 16, 20, 24, 32];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(fitnessRepositoryProvider).loadProfile();
    if (!mounted) return;
    setState(() {
      _height.text = p.heightCm?.toString() ?? '';
      _weight.text = p.weightKg?.toString() ?? '';
      _age.text = p.age?.toString() ?? '';
      _injuries.text = p.injuries ?? '';
      _sex = p.sex;
      _exp = p.experience;
      _goal = p.goal;
      _minutes = p.dailyMinutes;
      _kbs
        ..clear()
        ..addAll(p.kettlebellsKg);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _age.dispose();
    _injuries.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_kbs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先选一下手边有哪些壶铃重量')),
      );
      return;
    }
    setState(() => _saving = true);
    final p = FitnessProfile(
      heightCm: int.tryParse(_height.text.trim()),
      weightKg: double.tryParse(_weight.text.trim()),
      age: int.tryParse(_age.text.trim()),
      sex: _sex,
      kettlebellsKg: _kbs.toList()..sort(),
      experience: _exp,
      dailyMinutes: _minutes,
      goal: _goal,
      injuries: _injuries.text.trim().isEmpty ? null : _injuries.text.trim(),
    );
    await ref.read(fitnessRepositoryProvider).saveProfile(p);
    await DailyPlanNotifier.schedule(); // 默认 21:00
    if (!mounted) return;
    setState(() => _saving = false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('我的健身资料'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          _num('身高 (cm)', _height),
          _num('体重 (kg)', _weight, decimal: true),
          _num('年龄', _age),
          const SizedBox(height: 12),
          _seg<Sex>('性别', _sex, {Sex.male: '男', Sex.female: '女'},
              (v) => setState(() => _sex = v)),
          const SizedBox(height: 12),
          _seg<Goal>('目标', _goal,
              {Goal.cut: '减脂', Goal.maintain: '保持', Goal.gain: '增肌'},
              (v) => setState(() => _goal = v)),
          const SizedBox(height: 12),
          _seg<Experience>('训练水平', _exp,
              {Experience.novice: '新手', Experience.intermediate: '进阶'},
              (v) => setState(() => _exp = v)),
          const SizedBox(height: 16),
          const Text('手边的壶铃 (kg)',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kbOptions.map((kg) {
              final on = _kbs.contains(kg);
              return GestureDetector(
                onTap: () => setState(
                    () => on ? _kbs.remove(kg) : _kbs.add(kg)),
                child: CreamPill(
                  label: '$kg',
                  background: on ? AppColors.peach300 : AppColors.cream100,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('每天可训练时间：$_minutes 分钟',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 14)),
          Slider(
            value: _minutes.toDouble(),
            min: 10,
            max: 60,
            divisions: 10,
            label: '$_minutes',
            onChanged: (v) => setState(() => _minutes = v.round()),
          ),
          const SizedBox(height: 8),
          const Text('伤病 / 不能做的动作（选填）',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _injuries,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '比如：腰不好，避免硬拉类动作',
            ),
          ),
          const SizedBox(height: 24),
          CreamButton(
            label: _saving ? '保存中…' : '保存',
            emoji: _saving ? null : '💾',
            full: true,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _num(String label, TextEditingController c, {bool decimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: c,
        keyboardType:
            TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              RegExp(decimal ? r'[0-9.]' : r'[0-9]')),
        ],
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _seg<T>(String label, T value, Map<T, String> options,
      ValueChanged<T> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.entries.map((e) {
            final on = e.key == value;
            return GestureDetector(
              onTap: () => onChange(e.key),
              child: CreamPill(
                label: e.value,
                background: on ? AppColors.peach300 : AppColors.cream100,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
