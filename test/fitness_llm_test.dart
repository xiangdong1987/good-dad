import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/core/llm/llm_client.dart';
import 'package:good_dad/core/llm/types.dart';
import 'package:good_dad/features/fitness/fitness_llm.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';

/// 记录调用参数的假客户端。LlmClient 是抽象类，手写比上 mock 框架清楚。
class _FakeClient implements LlmClient {
  final String reply;
  final Object? throws;
  bool? sawNeedsVision;
  List<LlmMessage>? sawMessages;

  _FakeClient({this.reply = '{}', this.throws});

  @override
  Future<LlmResult> chatOnce(
    List<LlmMessage> messages, {
    String? model,
    double? temperature,
    bool needsVision = false,
  }) async {
    sawNeedsVision = needsVision;
    sawMessages = messages;
    if (throws != null) throw throws!;
    return LlmResult(text: reply);
  }

  @override
  Stream<LlmChunk> chat(
    List<LlmMessage> messages, {
    String? model,
    double? temperature,
    bool needsVision = false,
  }) =>
      const Stream.empty();
}

const _reply =
    '{"foods":[{"name":"饺子","grams":200,"kcal":460,"proteinG":18,'
    '"carbG":56,"fatG":18}],"kcal":460,"proteinG":18,"carbG":56,'
    '"fatG":18,"note":"蛋白够了"}';

void main() {
  test('文字记餐走非 vision 通道，别按图片计费', () async {
    final c = _FakeClient(reply: _reply);
    await FitnessLlm(c).analyzeMealText(meal: Meal.dinner, description: '两个饺子');

    expect(c.sawNeedsVision, isFalse);
  });

  test('拍照记餐仍走 vision 通道', () async {
    final c = _FakeClient(reply: _reply);
    await FitnessLlm(c).analyzeMeal(
      meal: Meal.dinner,
      compressedBytes: Uint8List.fromList([1, 2, 3]),
    );

    expect(c.sawNeedsVision, isTrue);
  });

  test('描述原样传给模型', () async {
    final c = _FakeClient(reply: _reply);
    await FitnessLlm(c)
        .analyzeMealText(meal: Meal.dinner, description: '两个饺子一碗小米粥');

    final text = c.sawMessages!
        .expand((m) => m.parts)
        .whereType<TextPart>()
        .map((p) => p.text)
        .join('\n');
    expect(text, contains('两个饺子一碗小米粥'));
  });

  test('解析出带明细热量的结果', () async {
    final c = _FakeClient(reply: _reply);
    final a = await FitnessLlm(c)
        .analyzeMealText(meal: Meal.dinner, description: '两个饺子');

    expect(a.foods.single.kcal, 460);
    expect(a.hasItemDetail, isTrue);
    expect(a.totalKcal, 460);
  });

  test('LLM 报错包成 FitnessLlmError，带得上原因', () async {
    final c = _FakeClient(throws: const LlmException('超时'));

    expect(
      () => FitnessLlm(c)
          .analyzeMealText(meal: Meal.dinner, description: '两个饺子'),
      throwsA(isA<FitnessLlmError>()
          .having((e) => e.message, 'message', contains('超时'))),
    );
  });
}
