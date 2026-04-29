import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_dad/features/home/home_page.dart';

void main() {
  testWidgets('home page shows status banner', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomePage()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('good-dad'), findsOneWidget);
  });
}
