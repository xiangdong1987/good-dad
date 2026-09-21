import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/core/llm/types.dart';
import 'package:good_dad/features/fitness/fitness_met.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';
import 'package:good_dad/features/fitness/fitness_prompt.dart';

void main() {
  group('parseMeal', () {
    test('纯 JSON 直接解析', () {
      final r = FitnessPrompt.parseMeal('''
{"foods":[{"name":"米饭","grams":150},{"name":"鸡胸","grams":120}],
 "kcal":420,"proteinG":35,"carbG":50,"fatG":8,"note":"蛋白不错"}
''');
      expect(r.kcal, 420);
      expect(r.proteinG, 35);
      expect(r.foods.length, 2);
      expect(r.foods.first.name, '米饭');
      expect(r.note, '蛋白不错');
    });

    test('markdown 围栏包裹也能抠出 JSON', () {
      const raw = '```json\n{"foods":[],"kcal":300,"proteinG":10,"carbG":40,"fatG":9,"note":""}\n```';
      final r = FitnessPrompt.parseMeal(raw);
      expect(r.kcal, 300);
    });

    test('完全不是 JSON 返回全 0 并保留原文', () {
      const raw = '看不清这是什么菜';
      final r = FitnessPrompt.parseMeal(raw);
      expect(r.kcal, 0);
      expect(r.rawText, raw);
    });
  });

  group('parsePlan', () {
    test('解析训练动作与目标', () {
      final r = FitnessPrompt.parsePlan('''
{"trainingPlan":[{"move":"高脚杯深蹲","sets":3,"reps":10,"weightKg":16,"note":"慢下"}],
 "dietGuidance":"早餐加个蛋","kcalTarget":1900,"proteinTarget":120,
 "carbTarget":190,"fatTarget":55,"deficitSummary":"今天蛋白差30g"}
''');
      expect(r.trainingPlan.length, 1);
      expect(r.trainingPlan.first.move, '高脚杯深蹲');
      expect(r.trainingPlan.first.weightKg, 16);
      expect(r.targets.kcal, 1900);
      expect(r.dietGuidance, '早餐加个蛋');
      expect(r.deficitSummary, '今天蛋白差30g');
    });

    test('脏输出回退到空计划但保留原文', () {
      const raw = '抱歉今天没法生成';
      final r = FitnessPrompt.parsePlan(raw);
      expect(r.trainingPlan, isEmpty);
      expect(r.rawText, raw);
    });
  });

  group('mealSystemPrompt', () {
    test('包含严格 JSON 指令与餐次', () {
      final s = FitnessPrompt.mealSystemPrompt(Meal.lunch, byPhoto: true);
      expect(s, contains('JSON'));
      expect(s, contains('午餐'));
    });
  });

  group('planSystemPrompt 安全约束', () {
    test('显式纳入伤病禁忌与新手降负荷与可用壶铃', () {
      const p = FitnessProfile(
        heightCm: 175,
        weightKg: 70,
        age: 30,
        kettlebellsKg: [12, 16],
        experience: Experience.novice,
        injuries: '腰椎间盘突出',
      );
      final s = FitnessPrompt.planSystemPrompt(
        profile: p,
        totals: const DayTotals(kcal: 1500, proteinG: 90, carbG: 150, fatG: 40),
        trainingDone: false,
      );
      expect(s, contains('腰椎间盘突出'));
      expect(s, contains('12')); // 可用壶铃重量
      expect(s, contains('16'));
      expect(s.toLowerCase(), contains('json'));
    });
  });

  group('训练动作类型标注', () {
    test('prompt 里列出所有可选类型，让 LLM 直接标而不是我们猜词', () {
      final msgs = FitnessPrompt.buildPlanMessages(
        profile: const FitnessProfile(
            heightCm: 178, weightKg: 94, age: 35, kettlebellsKg: [20]),
        totals: const DayTotals(kcal: 1800),
        trainingDone: false,
      );
      final text = msgs
          .expand((m) => m.parts)
          .whereType<TextPart>()
          .map((p) => p.text)
          .join('\n');
      expect(text, contains('kind'));
      for (final k in ActivityKind.training) {
        expect(text, contains(k.name), reason: '\${k.name} 没出现在 prompt 里');
      }
    });

    test('parsePlan 读出 LLM 标注的 kind', () {
      const raw =
          '{"trainingPlan":[{"move":"壶铃摆动","sets":3,"reps":15,'
          '"weightKg":20,"note":"髋部发力","kind":"kbBallistic"}],'
          '"dietGuidance":"多吃蛋白","kcalTarget":2000,"proteinTarget":150,'
          '"carbTarget":200,"fatTarget":67,"deficitSummary":"今天欠了点"}';
      final plan = FitnessPrompt.parsePlan(raw);
      expect(plan.trainingPlan.single.kind, ActivityKind.kbBallistic);
    });

    test('LLM 没给 kind 时留空，由关键词兜底', () {
      const raw =
          '{"trainingPlan":[{"move":"壶铃摆动","sets":3,"reps":15,'
          '"weightKg":20}],"dietGuidance":"","kcalTarget":2000,'
          '"proteinTarget":150,"carbTarget":200,"fatTarget":67,'
          '"deficitSummary":""}';
      final plan = FitnessPrompt.parsePlan(raw);
      expect(plan.trainingPlan.single.kind, isNull);
      expect(FitnessMet.kindOf(plan.trainingPlan.single),
          ActivityKind.kbBallistic);
    });
  });

  group('记餐 prompt', () {
    test('要求每样食物都带上自己的热量与宏量', () {
      final p = FitnessPrompt.mealSystemPrompt(Meal.lunch, byPhoto: true);
      expect(p, contains('kcal'));
      expect(p, contains('proteinG'));
      // 明细里要有，不能只在整餐层面要
      final foodsPart = p.substring(p.indexOf('"foods"'));
      expect(foodsPart.substring(0, foodsPart.indexOf(']')), contains('kcal'));
    });

    test('文字输入时措辞不提照片', () {
      final byText = FitnessPrompt.mealSystemPrompt(Meal.lunch, byPhoto: false);
      expect(byText, isNot(contains('照片')));
      expect(byText, contains('午餐'));
    });

    test('拍照时措辞提照片', () {
      final byPhoto = FitnessPrompt.mealSystemPrompt(Meal.lunch, byPhoto: true);
      expect(byPhoto, contains('照片'));
    });

    test('文字消息里不含图片部件', () {
      final msgs = FitnessPrompt.buildMealTextMessages(Meal.dinner, '两个饺子一碗粥');
      expect(msgs.expand((m) => m.parts).whereType<ImagePart>(), isEmpty);
      final text = msgs
          .expand((m) => m.parts)
          .whereType<TextPart>()
          .map((p) => p.text)
          .join('\n');
      expect(text, contains('两个饺子一碗粥'));
    });

    test('parseMeal 读出每样食物的热量', () {
      const raw =
          '{"foods":[{"name":"米饭","grams":150,"kcal":174,"proteinG":4,'
          '"carbG":39,"fatG":0}],"kcal":174,"proteinG":4,"carbG":39,'
          '"fatG":0,"note":"还行"}';
      final a = FitnessPrompt.parseMeal(raw);
      expect(a.foods.single.kcal, 174);
      expect(a.hasItemDetail, isTrue);
      expect(a.totalKcal, 174);
    });
  });
}
