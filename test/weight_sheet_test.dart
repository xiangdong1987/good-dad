import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/widgets/weight_sheet.dart';
import 'package:good_dad/ui/theme.dart';

/// 开一个按钮把弹窗推出来，好拿到它的返回值。
Future<double?> _open(
  WidgetTester tester, {
  double? initialKg,
  double? lastKg,
}) async {
  double? result;
  var returned = false;
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showWeightSheet(context,
                initialKg: initialKg, lastKg: lastKg);
            returned = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  addTearDown(() => returned);
  return result;
}

void main() {
  testWidgets('默认值取上次体重', (tester) async {
    await _open(tester, initialKg: 92.3, lastKg: 92.3);
    expect(find.textContaining('92.3'), findsWidgets);
  });

  testWidgets('步进按钮按 0.1 和 0.5 调整', (tester) async {
    await _open(tester, initialKg: 92.0, lastKg: 92.0);

    await tester.tap(find.text('+0.5'));
    await tester.pump();
    expect(find.textContaining('92.5'), findsWidgets);

    await tester.tap(find.text('−0.1'));
    await tester.pump();
    expect(find.textContaining('92.4'), findsWidgets);
  });

  testWidgets('确认后把体重返回给调用方', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showWeightSheet(context,
                    initialKg: 92.0, lastKg: 92.0)
                .then((v) => _captured = v),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+0.5'));
    await tester.pump();
    await tester.tap(find.text('记下来'));
    await tester.pumpAndSettle();

    expect(_captured, 92.5);
  });

  testWidgets('跳变超过阈值时先要二次确认，不直接返回', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showWeightSheet(context,
                    initialKg: 82.0, lastKg: 92.0)
                .then((v) => _captured = v),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    _captured = null;
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('记下来'));
    await tester.pumpAndSettle();

    // 弹出确认，还没返回值
    expect(find.textContaining('比上次少了 10 kg'), findsOneWidget);
    expect(_captured, isNull);

    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(_captured, 82.0);
  });
}

double? _captured;
