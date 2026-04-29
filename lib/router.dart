import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_page.dart';
import 'features/settings/settings_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('迷路了')),
    body: Center(child: Text('页面不存在: ${state.uri}')),
  ),
);
