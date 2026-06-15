import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/secure_storage.dart';

/// 跟踪「voice 教学已看过」状态，存在 SecureStorage（不打扰跨设备同步）。
class VoiceOnboardingController extends AsyncNotifier<bool> {
  static const _key = 'voice.onboarding_seen';
  late final SecureStorage _storage;

  @override
  Future<bool> build() async {
    _storage = SecureStorage();
    final v = await _storage.read(_key);
    return v == '1';
  }

  Future<void> markSeen() async {
    state = const AsyncData(true);
    await _storage.write(_key, '1');
  }

  /// debug：清掉重新看教学
  Future<void> reset() async {
    state = const AsyncData(false);
    await _storage.delete(_key);
  }
}

final voiceOnboardingProvider =
    AsyncNotifierProvider<VoiceOnboardingController, bool>(
        VoiceOnboardingController.new);
