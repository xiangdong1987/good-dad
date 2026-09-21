import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';
import 'package:good_dad/features/fitness/widgets/food_list_editor.dart';
import 'package:good_dad/ui/theme.dart';

const _rice = FoodItem('米饭', 150, kcal: 174, proteinG: 4, carbG: 39, fatG: 0);
const _chicken =
    FoodItem('鸡胸', 120, kcal: 198, proteinG: 37, carbG: 0, fatG: 4);

Future<List<FoodItem>?> _pump(
  WidgetTester tester, {
  List<FoodItem> foods = const [_rice, _chicken],
  Future<FoodItem?> Function()? onAdd,
}) async {
  List<FoodItem>? latest;
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: FoodListEditor(
          foods: foods,
          onChanged: (v) => latest = v,
          onAdd: onAdd ?? () async => null,
        ),
      ),
    ),
  ));
  return latest;
}

void main() {
  testWidgets('每样食物都列出名称、克数和自己的热量', (tester) async {
    await _pump(tester);

    expect(find.textContaining('米饭'), findsOneWidget);
    expect(find.textContaining('150'), findsWidgets);
    expect(find.textContaining('174'), findsWidgets);
    expect(find.textContaining('鸡胸'), findsOneWidget);
  });

  testWidgets('删除一样后回调里不再有它', (tester) async {
    List<FoodItem>? latest;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FoodListEditor(
            foods: const [_rice, _chicken],
            onChanged: (v) => latest = v,
            onAdd: () async => null,
          ),
        ),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('del-米饭')));
    await tester.pump();

    expect(latest, hasLength(1));
    expect(latest!.single.name, '鸡胸');
  });

  testWidgets('加量按比例把该项热量一起放大', (tester) async {
    List<FoodItem>? latest;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FoodListEditor(
            foods: const [_rice],
            onChanged: (v) => latest = v,
            onAdd: () async => null,
          ),
        ),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('plus-米饭')));
    await tester.pump();

    expect(latest!.single.grams, 175);
    expect(latest!.single.kcal, 203); // 174 * 175/150
  });

  testWidgets('减量按比例缩小', (tester) async {
    List<FoodItem>? latest;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FoodListEditor(
            foods: const [_rice],
            onChanged: (v) => latest = v,
            onAdd: () async => null,
          ),
        ),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('minus-米饭')));
    await tester.pump();

    expect(latest!.single.grams, 125);
    expect(latest!.single.kcal, 145);
  });

  testWidgets('克数减到 0 就停住，不出现负克重', (tester) async {
    List<FoodItem>? latest;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FoodListEditor(
            foods: const [FoodItem('一小口', 10, kcal: 12)],
            onChanged: (v) => latest = v,
            onAdd: () async => null,
          ),
        ),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('minus-一小口')));
    await tester.pump();

    expect(latest!.single.grams, 0);
  });

  testWidgets('新增食物把 onAdd 拿回来的结果追加到清单末尾', (tester) async {
    List<FoodItem>? latest;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FoodListEditor(
            foods: const [_rice],
            onChanged: (v) => latest = v,
            onAdd: () async =>
                const FoodItem('可乐', 330, kcal: 139, carbG: 35),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('加一样'));
    await tester.pumpAndSettle();

    expect(latest, hasLength(2));
    expect(latest!.last.name, '可乐');
    expect(latest!.last.kcal, 139);
  });

  testWidgets('onAdd 返回 null（取消或失败）时根本不该回调', (tester) async {
    final calls = <List<FoodItem>>[];
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FoodListEditor(
            foods: const [_rice],
            onChanged: calls.add,
            onAdd: () async => null,
          ),
        ),
      ),
    ));

    await tester.tap(find.text('加一样'));
    await tester.pumpAndSettle();

    // 用原列表回调一次也算脏改动：会把 edited 标记误置为 true
    expect(calls, isEmpty);
  });

  testWidgets('清单为空时给提示而不是空白', (tester) async {
    await _pump(tester, foods: const []);
    expect(find.textContaining('还没有'), findsOneWidget);
  });
}
