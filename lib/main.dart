import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notification/weekly_notifier.dart';
import 'core/profile/profile.dart';
import 'core/profile/profile_repository.dart';
import 'router.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 通知插件 + 时区初始化（一次即可；scheduleAll 在 profile 配好后才会触发）
  await WeeklyNotifier.init();

  runApp(const ProviderScope(child: GoodDadApp()));
}

class GoodDadApp extends ConsumerWidget {
  const GoodDadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // profile 完整时确保通知已调度（用户卸载重装 / 系统清掉了排程也能复活）
    final initial = ref.read(profileProvider).valueOrNull;
    if (initial != null && initial.isComplete) {
      WeeklyNotifier.scheduleAll();
    }
    ref.listen<AsyncValue<FamilyProfile>>(profileProvider, (_, next) {
      final p = next.valueOrNull;
      if (p != null && p.isComplete) {
        WeeklyNotifier.scheduleAll();
      }
    });

    return MaterialApp.router(
      title: 'GoodDad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
