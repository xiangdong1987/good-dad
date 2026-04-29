import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'ui/theme.dart';

void main() {
  runApp(const ProviderScope(child: GoodDadApp()));
}

class GoodDadApp extends StatelessWidget {
  const GoodDadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GoodDad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
