import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_dad/features/home/home_page.dart';
import 'package:good_dad/ui/theme.dart';

void main() {
  testWidgets('home page renders skill grid', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomePage(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('能不能吃'), findsOneWidget);
    expect(find.text('今天能帮上什么？'), findsOneWidget);
  });
}
