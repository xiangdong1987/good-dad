import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/i18n/app_locale.dart';
import 'core/i18n/locale_provider.dart';
import 'core/notification/weekly_notifier.dart';
import 'core/profile/profile.dart';
import 'core/profile/profile_repository.dart';
import 'features/fitness/fitness_plan_service.dart';
import 'router.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WeeklyNotifier.init();
  runApp(const ProviderScope(child: GoodDadApp()));
}

class GoodDadApp extends ConsumerStatefulWidget {
  const GoodDadApp({super.key});

  @override
  ConsumerState<GoodDadApp> createState() => _GoodDadAppState();
}

class _GoodDadAppState extends ConsumerState<GoodDadApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePlan());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _ensurePlan();
  }

  /// 训练计划的生成挂在 App 级而不是壶铃页：不进那一页也该有计划。
  void _ensurePlan() {
    ref.read(fitnessPlanServiceProvider).ensurePlan();
  }

  @override
  Widget build(BuildContext context) {
    // profile 完整时确保通知已调度
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

    final locale =
        ref.watch(localeProvider).valueOrNull ?? AppLocale.zhCN;

    return MaterialApp.router(
      title: 'GoodDad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
      locale: locale.toFlutterLocale(),
      supportedLocales: AppLocale.values
          .map((l) => l.toFlutterLocale())
          .toList(growable: false),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
