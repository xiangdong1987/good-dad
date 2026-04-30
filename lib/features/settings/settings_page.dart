import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/llm_config.dart';
import '../../core/config/llm_config_provider.dart';
import '../../core/llm/llm_providers.dart';
import '../../core/llm/openai_compatible_client.dart';
import '../../core/llm/types.dart';
import '../../core/memory/memory_repository.dart';
import '../../core/notification/weekly_notifier.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _baseUrlCtl = TextEditingController();
  final _apiKeyCtl = TextEditingController();
  final _chatModelCtl = TextEditingController();
  final _visionModelCtl = TextEditingController();

  bool _hydrated = false;
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;

  @override
  void dispose() {
    _baseUrlCtl.dispose();
    _apiKeyCtl.dispose();
    _chatModelCtl.dispose();
    _visionModelCtl.dispose();
    super.dispose();
  }

  void _hydrate(LlmConfig cfg) {
    _baseUrlCtl.text = cfg.baseUrl;
    _apiKeyCtl.text = cfg.apiKey;
    _chatModelCtl.text = cfg.chatModel;
    _visionModelCtl.text = cfg.visionModel;
    _hydrated = true;
  }

  Future<void> _save() async {
    final cfg = LlmConfig(
      baseUrl: _baseUrlCtl.text.trim(),
      apiKey: _apiKeyCtl.text.trim(),
      chatModel: _chatModelCtl.text.trim(),
      visionModel: _visionModelCtl.text.trim(),
    );
    await ref.read(llmConfigProvider.notifier).save(cfg);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
    }
  }

  Future<void> _showAvailableModels() async {
    setState(() => _testing = true);
    await _save();
    final client = ref.read(llmClientProvider);
    if (client == null) {
      setState(() {
        _testing = false;
        _testOk = false;
        _testResult = '配置不完整，先填 baseURL + API Key';
      });
      return;
    }
    try {
      final models = await (client as OpenAICompatibleClient).listModels();
      if (!mounted) return;
      setState(() {
        _testing = false;
        _testOk = true;
        _testResult = '✅ 共 ${models.length} 个可用模型，点列表回填';
      });
      await _showPicker(models);
    } on LlmException catch (e) {
      if (!mounted) return;
      setState(() {
        _testing = false;
        _testOk = false;
        _testResult = '❌ ${e.statusCode ?? ''} ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testing = false;
        _testOk = false;
        _testResult = '❌ $e';
      });
    }
  }

  Future<void> _showPicker(List<String> models) async {
    if (models.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('服务端返回空列表')),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('点条目把 id 填到当前选中的模型字段',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: models.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(models[i],
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 13)),
                    onTap: () => Navigator.of(ctx).pop(models[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    // 哪个输入框最后被聚焦过——用 selection 简单点，全填到两个字段
    setState(() {
      if (_chatModelCtl.text.trim().isEmpty ||
          _chatModelCtl.text == _visionModelCtl.text) {
        _chatModelCtl.text = picked;
        _visionModelCtl.text = picked;
      } else {
        _visionModelCtl.text = picked;
      }
    });
  }

  Future<void> _runTest() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    await _save();
    final client = ref.read(llmClientProvider);
    if (client == null) {
      setState(() {
        _testing = false;
        _testOk = false;
        _testResult = '配置不完整';
      });
      return;
    }
    try {
      final reply = await (client as OpenAICompatibleClient).testEcho();
      setState(() {
        _testOk = true;
        _testResult = '✅ $reply';
      });
    } on LlmException catch (e) {
      setState(() {
        _testOk = false;
        _testResult = '❌ ${e.statusCode ?? ''} ${e.message}';
      });
    } catch (e) {
      setState(() {
        _testOk = false;
        _testResult = '❌ $e';
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfgAsync = ref.watch(llmConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: cfgAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('读取配置失败: $e')),
        data: (cfg) {
          if (!_hydrated) _hydrate(cfg);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionTitle('LLM 服务'),
              const SizedBox(height: 8),
              Text(
                '使用 OpenAI 兼容协议（Chat Completions）。可填 OpenAI 官方、DeepSeek、通义千问、豆包、本地 Ollama 等任意兼容服务。',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _baseUrlCtl,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: '例如 https://api.openai.com/v1',
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apiKeyCtl,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'sk-...',
                ),
                obscureText: true,
                autocorrect: false,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _chatModelCtl,
                decoration: const InputDecoration(
                  labelText: '聊天模型 (chat model)',
                  hintText: '例如 gpt-4o-mini / deepseek-chat',
                ),
                autocorrect: false,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _visionModelCtl,
                decoration: const InputDecoration(
                  labelText: '视觉模型 (vision model)',
                  hintText: '例如 gpt-4o / qwen-vl-plus',
                ),
                autocorrect: false,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _testing ? null : _showAvailableModels,
                icon: const Icon(Icons.list_alt_outlined),
                label: const Text('查看服务端可用模型'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _testing ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('保存'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _testing ? null : _runTest,
                      icon: _testing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bolt_outlined),
                      label: const Text('保存并测试'),
                    ),
                  ),
                ],
              ),
              if (_testResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _testOk
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                  ),
                  child: Text(_testResult!),
                ),
              ],
              const SizedBox(height: 32),
              const _SectionTitle('家庭'),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.family_restroom_rounded),
                title: const Text('家庭信息'),
                subtitle: const Text('改称呼 / 当前孕周'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile-edit'),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_rounded),
                title: const Text('日历'),
                subtitle: const Text('每天的安排 + 孕周'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/calendar'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('测试通知'),
                subtitle: const Text('确认通知通道是通的'),
                trailing: const Icon(Icons.send_outlined),
                onTap: () async {
                  await WeeklyNotifier.requestPermissions();
                  await WeeklyNotifier.debugFireOnce();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已发送一条测试通知')),
                  );
                },
              ),
              const SizedBox(height: 24),
              const _SectionTitle('数据'),
              const SizedBox(height: 8),
              Consumer(builder: (ctx, ref, _) {
                final pending =
                    ref.watch(pendingMemoryCountProvider).valueOrNull ?? 0;
                return ListTile(
                  leading: const Icon(Icons.memory_outlined),
                  title: const Text('记忆管理'),
                  subtitle: Text(pending == 0
                      ? '聊天里我会帮你沉淀长期事实'
                      : '$pending 条待确认 · 去看看'),
                  trailing: pending > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(ctx).colorScheme.error,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('$pending',
                              style: TextStyle(
                                  color: Theme.of(ctx)
                                      .colorScheme
                                      .onError,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => context.push('/memory'),
                );
              }),
              ListTile(
                leading: const Icon(Icons.extension_outlined),
                title: const Text('技能列表'),
                subtitle: const Text('查看内置 SKILL.md'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/skills'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
}
