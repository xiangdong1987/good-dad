# Voice Agent Prompt 架构

> 类比 OpenClaw（NanoClaw v2）的 「skill hot-load」：能力扩展不改 prompt 框架。

## 原则

System prompt 是个 **6-slot 模板**，每个 slot 由独立模块填内容。AGENT.md 是 meta-instruction，告诉 LLM **怎么思考各个 slot**，而不是把规则全枚举。

```
┌─ Layer 1 · AGENT.md body ────────────┐  meta-instruction（永远在）
├─ Layer 2 · ## 家庭信息 ─────────────┤  FamilyProfile（永远在）
├─ Layer 3 · ## 用户偏好 ─────────────┤  profile.md（可选）
├─ Layer 4 · ## 记忆 ────────────────┤  MemoryInjector（可选）
├─ Layer 5 · ## 当前页 ──────────────┤  PageContext（可选）
└─ Layer 6 · ## 工具 ────────────────┘  AgentToolRegistry（永远在 + 页面感知）
```

超长时按 5 → 4 → 3 优先级丢层；layer 1+2+6 永远保留。

## 文件分布

| 文件 | 责任 |
|---|---|
| `assets/agent/AGENT.md` | Layer 1 · meta-instruction |
| `lib/core/voice/harness/system_prompt_builder.dart` | 拼装六层 |
| `lib/core/profile/profile.dart` | Layer 2 · FamilyProfile 数据源 |
| `lib/core/agent_config/agent_profile_repository.dart` | Layer 3 · profile.md 读写 |
| `lib/core/memory/memory_injector.dart` | Layer 4 · 按 memory_keys 过滤 |
| `lib/core/voice/agent/page_context_provider.dart` | Layer 5 · 当前页面状态 |
| `lib/core/voice/agent/agent_tool_registry.dart` | Layer 6 · 工具注册表 |

## 扩展方式

### 加一个新工具（最常见）

```dart
// 1. 写 tool 类
class WaterReminderTool extends AgentTool {
  @override String get name => 'remind_water';
  @override String get descriptionZh => '设个喝水提醒';
  @override String get argsHint => 'every:string(每 X 小时)';
  @override bool get writes => true;  // 出现「[写库 · 撤销]」标记
  @override List<ToolExample> get examples => const [
    ToolExample('每两小时提醒我喝水', {'every': '2h'}),
  ];
  @override Future<ToolResult> invoke(args, ctx) async { ... }
}

// 2. registry 加一行
final agentToolRegistryProvider = Provider<AgentToolRegistry>(
  (ref) => AgentToolRegistry([
    AddCalendarTaskTool(),
    NavigateToTool(),
    WaterReminderTool(),  // ← 新加
    ...
  ]),
);
```

**不需要改 AGENT.md**，模型从 examples 学到何时调。

### 加一个新页面上下文（如「肚肚照」页）

```dart
// 在 belly_photo_page.dart
@override
void dispose() {
  ref.read(pageContextProvider.notifier).state = null;
  super.dispose();
}

void _onPhotoTaken(BellyPhoto photo) {
  ref.read(pageContextProvider.notifier).state = PageContext(
    kind: 'belly_photo',
    payload: {'week': photo.week, 'thumbnailHash': photo.hash},
  );
}
```

工具如果只想在这个页可用：

```dart
class CompareWithLastWeekTool extends AgentTool {
  @override String? get requiresPageKind => 'belly_photo';
  ...
}
```

### 加一类新记忆（如「饮食偏好」）

只要写库时 `MemoryEntry.name` 用前缀（如 `preference.diet.*`），AGENT.md 的 memory_keys 已经包含 `preference.*` 通配匹配，直接被注入。

如果是新前缀（如 `health.*`）：

```yaml
# assets/agent/AGENT.md frontmatter
context:
  memory_keys: ["self.*", "partner.*", "baby.*", "preference.*", "health.*"]
```

### 加一种新输入模态（如视频）

1. 在 `harness/harness_input.dart` 加 `VideoHarnessInput extends HarnessInput`
2. 写一个新 reasoner 处理它（或扩展 MimoReasoner）
3. orchestrator 加一个新入口方法
4. 不用动 AGENT.md / system_prompt_builder

## 不应该做的事

❌ **在 AGENT.md 里枚举工具触发规则** —— 工具自带 `examples` 就行，规则散在两处易漂  
❌ **写"如果用户说 X 就 Y"** —— 给模型 examples 让它自己 generalize  
❌ **在 system_prompt_builder 里硬编码 page kind 特殊处理** —— 走 PageContext 通用通道  
❌ **改一次 AGENT.md 就要重新发版** —— 高频迭代的内容应该走 profile.md 或 examples
