import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/baby_shopping/shopping_page.dart';
import 'features/belly_photo/belly_photo_page.dart';
import 'features/calendar/calendar_page.dart';
import 'features/chat/chat_page.dart';
import 'features/checklist/checklist_page.dart';
import 'features/food_safety/food_safety_page.dart';
import 'features/home/home_page.dart';
import 'features/italian_license/italian_license_page.dart';
import 'features/memory/memory_list_page.dart';
import 'features/pregnancy/pregnancy_week_page.dart';
import 'features/pregnancy_recipe/recipe_page.dart';
import 'features/profile_edit/profile_edit_page.dart';
import 'features/settings/settings_page.dart';
import 'features/skills/skill_list_page.dart';

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
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: '/memory',
      name: 'memory',
      builder: (context, state) => const MemoryListPage(),
    ),
    GoRoute(
      path: '/skills',
      name: 'skills',
      builder: (context, state) => const SkillListPage(),
    ),
    GoRoute(
      path: '/calendar',
      name: 'calendar',
      builder: (context, state) => const CalendarPage(),
    ),
    GoRoute(
      path: '/profile-edit',
      name: 'profile-edit',
      builder: (context, state) => const ProfileEditPage(),
    ),
    // 6 个 Skill 屏（食物识别已联通；其余仍是视觉 mock，留待后续里程碑接入）
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
    GoRoute(
      path: '/italian-license',
      name: 'italian-license',
      builder: (context, state) => const ItalianLicensePage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('迷路了')),
    body: Center(child: Text('页面不存在: ${state.uri}')),
  ),
);
