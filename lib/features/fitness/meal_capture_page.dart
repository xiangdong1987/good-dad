import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/storage/file_store.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'fitness_llm.dart';
import 'fitness_models.dart';
import 'fitness_prompt.dart';
import 'fitness_repository.dart';
import 'widgets/food_list_editor.dart';

/// 拍一餐 → AI 分析 → 可编辑结果 → 保存到 meal_log。
/// 通过构造参数拿到目标日期与餐次。
class MealCapturePage extends ConsumerStatefulWidget {
  final String date;
  final Meal meal;
  const MealCapturePage({super.key, required this.date, required this.meal});

  @override
  ConsumerState<MealCapturePage> createState() => _MealCapturePageState();
}

class _MealCapturePageState extends ConsumerState<MealCapturePage> {
  final _picker = ImagePicker();
  Uint8List? _bytes;
  MealAnalysis? _result;
  String? _error;
  bool _running = false;

  /// 一句话描述的输入框。
  final _desc = TextEditingController();

  /// 编辑既有记录时保留原照片，别因为没重拍就把照片弄丢。
  String? _existingPhotoPath;
  bool _loaded = false;

  // 可编辑字段
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carb = TextEditingController();
  final _fat = TextEditingController();
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  /// 这餐已经记过就把数据读回来，进入编辑而不是重新记一遍。
  Future<void> _loadExisting() async {
    final rows =
        await ref.read(fitnessRepositoryProvider).mealsForDate(widget.date);
    final row = rows.where((r) => r.meal == widget.meal.name).firstOrNull;
    if (!mounted) return;
    if (row == null) {
      setState(() => _loaded = true);
      return;
    }
    final foods = (jsonDecode(row.foodsJson) as List)
        .map((e) => FoodItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    setState(() {
      _loaded = true;
      _existingPhotoPath = row.photoPath;
      _result = MealAnalysis(
        foods: foods,
        kcal: row.kcal,
        proteinG: row.proteinG,
        carbG: row.carbG,
        fatG: row.fatG,
      );
      _kcal.text = row.kcal.toString();
      _protein.text = row.proteinG.toString();
      _carb.text = row.carbG.toString();
      _fat.text = row.fatG.toString();
    });
  }

  @override
  void dispose() {
    _desc.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carb.dispose();
    _fat.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    if (_running) return;
    final llm = ref.read(fitnessLlmProvider);
    if (llm == null) {
      setState(() => _error = '请先到「设置」配好 LLM（baseURL + key + 视觉模型）');
      return;
    }
    try {
      final picked = await _picker.pickImage(
          source: source, maxWidth: 1600, imageQuality: 90);
      if (picked == null) return;
      final raw = await picked.readAsBytes();
      final compressed = FitnessPrompt.compressImage(raw);
      setState(() {
        _bytes = compressed;
        _result = null;
        _error = null;
        _running = true;
        _edited = false;
      });
      final res = await llm.analyzeMeal(
          meal: widget.meal, compressedBytes: compressed);
      if (!mounted) return;
      setState(() {
        _result = res;
        _running = false;
        _kcal.text = res.kcal.toString();
        _protein.text = res.proteinG.toString();
        _carb.text = res.carbG.toString();
        _fat.text = res.fatG.toString();
      });
    } on FitnessLlmError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _running = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '出错了: $e';
        _running = false;
      });
    }
  }

  /// 一句话描述记一餐。
  Future<void> _analyzeText() async {
    final text = _desc.text.trim();
    if (text.isEmpty || _running) return;
    final llm = ref.read(fitnessLlmProvider);
    if (llm == null) {
      setState(() => _error = '请先到「设置」配好 LLM（baseURL + key）');
      return;
    }
    setState(() {
      _error = null;
      _running = true;
    });
    try {
      final res =
          await llm.analyzeMealText(meal: widget.meal, description: text);
      if (!mounted) return;
      setState(() {
        _result = res;
        _running = false;
        _edited = false;
        _kcal.text = res.totalKcal.toString();
        _protein.text = res.totalProteinG.toString();
        _carb.text = res.totalCarbG.toString();
        _fat.text = res.totalFatG.toString();
      });
    } on FitnessLlmError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _running = false;
      });
    }
  }

  /// 新增一样食物：复用文字分析拿估值，不另起一条 LLM 通道。
  Future<FoodItem?> _addFood() async {
    final input = await showDialog<String>(
      context: context,
      builder: (c) {
        final ctl = TextEditingController();
        return AlertDialog(
          title: const Text('加一样'),
          content: TextField(
            controller: ctl,
            autofocus: true,
            decoration: const InputDecoration(hintText: '比如：一罐可乐 330ml'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(), child: const Text('算了')),
            TextButton(
                onPressed: () => Navigator.of(c).pop(ctl.text.trim()),
                child: const Text('让 AI 估')),
          ],
        );
      },
    );
    if (input == null || input.isEmpty) return null;

    final llm = ref.read(fitnessLlmProvider);
    if (llm == null) return null;
    setState(() => _running = true);
    try {
      final res =
          await llm.analyzeMealText(meal: widget.meal, description: input);
      if (mounted) setState(() => _running = false);
      return res.foods.isEmpty ? null : res.foods.first;
    } on FitnessLlmError catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _running = false;
        });
      }
      return null;
    }
  }

  Future<void> _save() async {
    final res = _result;
    if (res == null) return;
    // 编辑既有记录且没重拍时，沿用原来的照片。
    String? photoPath = _existingPhotoPath;
    if (_bytes != null) {
      photoPath = await ref.read(fileStoreProvider).saveMealPhoto(_bytes!);
    }
    // 明细齐全时整餐由明细之和决定，手填的四个数字只在没有明细时生效。
    final analysis = res.hasItemDetail
        ? res
        : MealAnalysis(
            foods: res.foods,
            kcal: int.tryParse(_kcal.text) ?? res.kcal,
            proteinG: int.tryParse(_protein.text) ?? res.proteinG,
            carbG: int.tryParse(_carb.text) ?? res.carbG,
            fatG: int.tryParse(_fat.text) ?? res.fatG,
            note: res.note,
          );
    await ref.read(fitnessRepositoryProvider).saveMeal(
          date: widget.date,
          meal: widget.meal,
          analysis: analysis,
          photoPath: photoPath,
          edited: _edited,
        );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _result != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text('记一餐 · ${widget.meal.zh}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          if (!_loaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_bytes == null && _result == null)
            CreamCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Sticker(
                        emoji: '🍽', size: 40, background: AppColors.mint300),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('拍一张，或者说两句',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: 15)),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _desc,
                    minLines: 2,
                    maxLines: 4,
                    enabled: !_running,
                    decoration: const InputDecoration(
                      hintText: '比如：两个饺子、一碗小米粥、一个煎蛋',
                    ),
                    onSubmitted: (_) => _analyzeText(),
                  ),
                  const SizedBox(height: 12),
                  CreamButton(
                    label: _running ? '分析中…' : '让 AI 拆解',
                    emoji: _running ? null : '✍️',
                    full: true,
                    onPressed: _running ? null : _analyzeText,
                  ),
                ],
              ),
            ),
          if (_bytes != null)
            CreamCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppRadius.lg - 2),
                child: Stack(children: [
                  AspectRatio(
                      aspectRatio: 1.4,
                      child: Image.memory(_bytes!, fit: BoxFit.cover)),
                  if (_running)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 12),
                            Text('AI 分析中…',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.rose300,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.ink900, width: 1.5),
              ),
              child: Text(_error!,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ],
          if (hasResult) ...[
            const SizedBox(height: 14),
            CreamCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_result!.hasItemDetail)
                    FoodListEditor(
                      foods: _result!.foods,
                      onAdd: _addFood,
                      onChanged: (next) => setState(() {
                        _result = _result!.withFoods(next);
                        _edited = true;
                      }),
                    )
                  else if (_result!.foods.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _result!.foods
                          .map((f) => CreamPill(
                              label: '${f.name} ${f.grams}g',
                              leadingEmoji: '🍴'))
                          .toList(),
                    ),
                  if (_result!.note.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(_result!.note,
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            height: 1.4)),
                  ],
                  const SizedBox(height: 12),
                  if (_result!.hasItemDetail)
                    Text(
                      '合计 ${_result!.totalKcal} 大卡 · 蛋白 ${_result!.totalProteinG}g'
                      ' · 碳水 ${_result!.totalCarbG}g · 脂肪 ${_result!.totalFatG}g',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.ink600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    )
                  else ...[
                    const Text('这餐没有逐项明细，只能改整体估算',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: AppColors.ink600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      _macroField('热量', _kcal),
                      const SizedBox(width: 8),
                      _macroField('蛋白', _protein),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      _macroField('碳水', _carb),
                      const SizedBox(width: 8),
                      _macroField('脂肪', _fat),
                    ]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            CreamButton(
                label: '保存这餐', emoji: '✅', full: true, onPressed: _save),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: CreamButton(
                label: _running ? '分析中…' : '拍照',
                emoji: _running ? null : '📷',
                full: true,
                onPressed: _running ? null : () => _pick(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 10),
            CreamButton(
              label: '相册',
              emoji: '🖼',
              ghost: true,
              onPressed: _running ? null : () => _pick(ImageSource.gallery),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _macroField(String label, TextEditingController c) {
    return Expanded(
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        onChanged: (_) => _edited = true,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
