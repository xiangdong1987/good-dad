import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';

void main() {
  group('FoodItem 明细热量', () {
    test('从 JSON 读出每样食物的热量与宏量', () {
      final f = FoodItem.fromJson(const {
        'name': '米饭',
        'grams': 150,
        'kcal': 174,
        'proteinG': 4,
        'carbG': 39,
        'fatG': 0,
      });
      expect(f.name, '米饭');
      expect(f.grams, 150);
      expect(f.kcal, 174);
      expect(f.carbG, 39);
    });

    test('LLM 没给明细热量时为 0，不瞎猜', () {
      final f = FoodItem.fromJson(const {'name': '米饭', 'grams': 150});
      expect(f.kcal, 0);
      expect(f.proteinG, 0);
    });

    test('往返 JSON 不丢字段', () {
      const f = FoodItem('鸡胸', 120, kcal: 198, proteinG: 37, carbG: 0, fatG: 4);
      final back = FoodItem.fromJson(f.toJson());
      expect(back.kcal, 198);
      expect(back.proteinG, 37);
      expect(back.fatG, 4);
    });
  });

  group('scaledTo 按克数缩放', () {
    const rice = FoodItem('米饭', 150, kcal: 174, proteinG: 4, carbG: 39, fatG: 0);

    test('加量按比例放大并取整', () {
      final bigger = rice.scaledTo(200);
      expect(bigger.grams, 200);
      expect(bigger.kcal, 232); // 174 * 200/150 = 232
      expect(bigger.carbG, 52); // 39 * 4/3 = 52
    });

    test('减量按比例缩小', () {
      final smaller = rice.scaledTo(75);
      expect(smaller.kcal, 87);
    });

    test('缩到 0 克则全为 0', () {
      final zero = rice.scaledTo(0);
      expect(zero.kcal, 0);
      expect(zero.proteinG, 0);
    });

    test('原克数为 0 时无法按比例推算，数值保持不变', () {
      const unknown = FoodItem('某物', 0, kcal: 100);
      expect(unknown.scaledTo(50).kcal, 100);
    });
  });

  group('整餐数值以明细之和为准', () {
    test('明细齐全时用明细之和，而不是 LLM 给的整餐值', () {
      const a = MealAnalysis(
        foods: [
          FoodItem('米饭', 150, kcal: 174, proteinG: 4, carbG: 39, fatG: 0),
          FoodItem('鸡胸', 120, kcal: 198, proteinG: 37, carbG: 0, fatG: 4),
        ],
        kcal: 999, // LLM 给的整餐值故意对不上
        proteinG: 999,
      );
      expect(a.hasItemDetail, isTrue);
      expect(a.totalKcal, 372);
      expect(a.totalProteinG, 41);
      expect(a.totalFatG, 4);
    });

    test('明细没有热量时退回 LLM 给的整餐值', () {
      const a = MealAnalysis(
        foods: [FoodItem('米饭', 150), FoodItem('鸡胸', 120)],
        kcal: 372,
        proteinG: 41,
      );
      expect(a.hasItemDetail, isFalse);
      expect(a.totalKcal, 372);
      expect(a.totalProteinG, 41);
    });

    test('完全没有明细时也退回整餐值', () {
      const a = MealAnalysis(kcal: 372, proteinG: 41);
      expect(a.hasItemDetail, isFalse);
      expect(a.totalKcal, 372);
    });

    test('只要有一样缺热量就算明细不全，不半信半疑', () {
      const a = MealAnalysis(
        foods: [
          FoodItem('米饭', 150, kcal: 174),
          FoodItem('说不清的菜', 100),
        ],
        kcal: 372,
      );
      expect(a.hasItemDetail, isFalse);
      expect(a.totalKcal, 372);
    });
  });

  group('编辑后重建', () {
    test('删掉一样食物后整餐跟着减', () {
      const a = MealAnalysis(
        foods: [
          FoodItem('米饭', 150, kcal: 174, proteinG: 4, carbG: 39, fatG: 0),
          FoodItem('鸡胸', 120, kcal: 198, proteinG: 37, carbG: 0, fatG: 4),
        ],
        kcal: 372,
      );
      final edited = a.withFoods([a.foods.first]);
      expect(edited.totalKcal, 174);
      expect(edited.totalProteinG, 4);
    });

    test('改克数后整餐实时重算', () {
      const a = MealAnalysis(
        foods: [
          FoodItem('米饭', 150, kcal: 174, proteinG: 4, carbG: 39, fatG: 0),
        ],
        kcal: 174,
      );
      final edited = a.withFoods([a.foods.first.scaledTo(300)]);
      expect(edited.totalKcal, 348);
    });

    test('删光之后整餐归零', () {
      const a = MealAnalysis(
        foods: [FoodItem('米饭', 150, kcal: 174)],
        kcal: 174,
      );
      expect(a.withFoods([]).totalKcal, 0);
    });
  });
}
