import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_dad/core/profile/profile.dart';
import 'package:good_dad/core/profile/profile_repository.dart';
import 'package:good_dad/features/home/home_page.dart';
import 'package:good_dad/features/onboarding/onboarding_page.dart';
import 'package:good_dad/ui/theme.dart';

class _StubProfileController extends ProfileController {
  final FamilyProfile profile;
  _StubProfileController(this.profile);
  @override
  Future<FamilyProfile> build() async => profile;
  @override
  Future<void> save(FamilyProfile next) async {
    state = AsyncData(next);
  }
}

void main() {
  testWidgets('home renders skill grid when profile is complete',
      (tester) async {
    final profile = FamilyProfile(
      dadName: '阿明',
      momName: '小芸',
      dueDate: DateTime.now().add(const Duration(days: 16 * 7)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider
              .overrideWith(() => _StubProfileController(profile)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('能不能吃'), findsOneWidget);
    expect(find.text('今天能帮上什么？'), findsOneWidget);
    expect(find.textContaining('阿明'), findsWidgets);
  });

  testWidgets('home falls back to onboarding when profile is empty',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider
              .overrideWith(() => _StubProfileController(FamilyProfile.empty)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('先认识一下'), findsOneWidget);
  });

  test('FamilyProfile.currentWeek 反推正确', () {
    final now = DateTime(2026, 4, 30);
    final due = FamilyProfile.dueDateFromCurrentWeek(24, now: now);
    final p = FamilyProfile(dadName: 'a', momName: 'b', dueDate: due);
    expect(p.currentWeek(now: now), 24);
    expect(p.weeksToDue(now: now), 16);
  });
}
