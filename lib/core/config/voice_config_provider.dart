import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_storage.dart';
import 'voice_config.dart';

class _Keys {
  static const ttsVoiceId = 'voice.tts_voice_id';
  static const speed = 'voice.speed';
}

class VoiceConfigController extends AsyncNotifier<VoiceConfig> {
  late final SecureStorage _storage;

  @override
  Future<VoiceConfig> build() async {
    _storage = SecureStorage();
    final speedStr = await _storage.read(_Keys.speed);
    return VoiceConfig(
      ttsVoiceId: await _storage.read(_Keys.ttsVoiceId) ?? '',
      speed: double.tryParse(speedStr ?? '') ?? 1.0,
    );
  }

  Future<void> save(VoiceConfig cfg) async {
    state = AsyncData(cfg);
    await _storage.write(_Keys.ttsVoiceId, cfg.ttsVoiceId);
    await _storage.write(_Keys.speed, cfg.speed.toStringAsFixed(2));
  }
}

final voiceConfigProvider =
    AsyncNotifierProvider<VoiceConfigController, VoiceConfig>(
        VoiceConfigController.new);
