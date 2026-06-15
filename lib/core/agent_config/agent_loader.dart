import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agent_doc.dart';

/// 加载 bundled `assets/agent/AGENT.md`。
///
/// 单例缓存；改 AGENT.md 后调 [invalidate] 让下次重读。
class AgentLoader {
  AgentDoc? _cache;

  Future<AgentDoc> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    try {
      final raw = await rootBundle.loadString('assets/agent/AGENT.md');
      final doc = AgentDoc.parse(raw);
      _cache = doc;
      return doc;
    } catch (_) {
      // assets 没找到时给空文档兜底，让 system_prompt_builder 不崩。
      return AgentDoc.empty;
    }
  }

  void invalidate() {
    _cache = null;
  }
}

final agentLoaderProvider = Provider<AgentLoader>((_) => AgentLoader());

/// 异步暴露当前加载好的 AGENT.md。
final agentDocProvider = FutureProvider<AgentDoc>((ref) async {
  return ref.watch(agentLoaderProvider).load();
});
