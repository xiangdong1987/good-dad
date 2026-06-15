import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/llm_config_provider.dart';
import '../llm_log/llm_log_repository.dart';
import 'llm_client.dart';
import 'openai_compatible_client.dart';

final llmClientProvider = Provider<LlmClient?>((ref) {
  final cfg = ref.watch(llmConfigProvider).valueOrNull;
  if (cfg == null || !cfg.isComplete) return null;
  return OpenAICompatibleClient(
    cfg,
    logger: ref.watch(llmLogRepositoryProvider),
  );
});
