import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'llm_config.dart';
import 'secure_storage.dart';

class _Keys {
  static const baseUrl = 'llm.base_url';
  static const apiKey = 'llm.api_key';
  static const chatModel = 'llm.chat_model';
  static const visionModel = 'llm.vision_model';
}

class LlmConfigController extends AsyncNotifier<LlmConfig> {
  late final SecureStorage _storage;

  @override
  Future<LlmConfig> build() async {
    _storage = SecureStorage();
    return LlmConfig(
      baseUrl: await _storage.read(_Keys.baseUrl) ?? '',
      apiKey: await _storage.read(_Keys.apiKey) ?? '',
      chatModel: await _storage.read(_Keys.chatModel) ?? '',
      visionModel: await _storage.read(_Keys.visionModel) ?? '',
    );
  }

  Future<void> save(LlmConfig cfg) async {
    state = AsyncData(cfg);
    await _storage.write(_Keys.baseUrl, cfg.baseUrl);
    await _storage.write(_Keys.apiKey, cfg.apiKey);
    await _storage.write(_Keys.chatModel, cfg.chatModel);
    await _storage.write(_Keys.visionModel, cfg.visionModel);
  }
}

final llmConfigProvider =
    AsyncNotifierProvider<LlmConfigController, LlmConfig>(
        LlmConfigController.new);
