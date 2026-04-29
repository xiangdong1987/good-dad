import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/baby_shopping/shopping_page.dart';
import 'features/belly_photo/belly_photo_page.dart';
import 'features/checklist/checklist_page.dart';
import 'features/food_safety/food_safety_page.dart';
import 'features/home/home_page.dart';
import 'features/pregnancy/pregnancy_week_page.dart';
import 'features/pregnancy_recipe/recipe_page.dart';
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
    // 6 个 Skill 屏（M1 阶段为视觉占位 mock，后续里程碑接入真实 LLM/数据）
    GoRoute(
      path: '/food',
      name: 'food',
      builder: (context, state) => const FoodSafetyPage(),
    ),
    GoRoute(
      path: '/week',
      name: 'week',
      builder: (context, state) => const PregnancyWeekPage(),
    ),
    GoRoute(
      path: '/recipe',
      name: 'recipe',
      builder: (context, state) => const RecipePage(),
    ),
    GoRoute(
      path: '/belly',
      name: 'belly',
      builder: (context, state) => const BellyPhotoPage(),
    ),
    GoRoute(
      path: '/checklist',
      name: 'checklist',
      builder: (context, state) => const ChecklistPage(),
    ),
    GoRoute(
      path: '/shopping',
      name: 'shopping',
      builder: (context, state) => const ShoppingPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('迷路了')),
    body: Center(child: Text('页面不存在: ${state.uri}')),
  ),
);
