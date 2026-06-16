import 'dart:typed_data';

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

  // 可编辑字段
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carb = TextEditingController();
  final _fat = TextEditingController();
  bool _edited = false;

  @override
  void dispose() {
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

  Future<void> _save() async {
    final res = _result;
    if (res == null) return;
    String? photoPath;
    if (_bytes != null) {
      photoPath = await ref.read(fileStoreProvider).saveMealPhoto(_bytes!);
    }
    final analysis = MealAnalysis(
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
          if (_bytes == null)
            CreamCard(
              child: SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Sticker(emoji: '🍽', size: 56, background: AppColors.mint300),
                      SizedBox(height: 10),
                      Text('拍一张这餐的照片',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ],
                  ),
                ),
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
                  if (_result!.foods.isNotEmpty)
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
                  const Text('估算（可改）',
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
