import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/i18n/app_locale.dart';
import 'core/i18n/locale_provider.dart';
import 'core/notification/weekly_notifier.dart';
import 'core/profile/profile.dart';
import 'core/profile/profile_repository.dart';
import 'core/voice/voice_keys.dart';
import 'router.dart';
import 'ui/theme.dart';
import 'ui/widgets/voice_button.dart';
import 'ui/widgets/voice_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WeeklyNotifier.init();
  runApp(const ProviderScope(child: GoodDadApp()));
}

class GoodDadApp extends ConsumerWidget {
  const GoodDadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      scaffoldMessengerKey: voiceMessengerKey,
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
      builder: (context, child) {
        final keyboardOpen =
            MediaQuery.of(context).viewInsets.bottom > 0;
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (!keyboardOpen)
              const Positioned(
                right: 16,
                bottom: 24,
                child: VoiceButton(),
              ),
            if (!keyboardOpen) const VoiceOverlay(),
          ],
        );
      },
    );
  }
}
