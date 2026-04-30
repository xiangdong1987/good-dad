# good-dad 路线图

## 1. 愿景

打造一款「给爸爸用的」育儿 AI 助手 Flutter App，底层借鉴 Claude Code（Cloud Code）：
所有能力都通过 SKILL.md 文件定义，添加新功能 = 写一份 markdown，无需改 Dart 代码（除非要新组件渲染特殊输出）。

- LLM：OpenAI 兼容协议，用户自配 baseURL + key + model
- 数据：SQLite + 文件，纯本地，零后端
- 记忆：受 Claude Code 启发的 user / feedback / project / reference 四类
- UI：圆润奶油可爱风（design-system/styles.css）

## 2. 架构总览

```
┌────────────────────────────────────────────────────────────┐
│              UI (Flutter + Riverpod + go_router)            │
│  Home · Chat · Skill 屏 · Settings · Memory · Onboarding    │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────▼────────┐    ┌─────────────────┐
        │   SkillRunner    │───►│   LlmClient     │
        │ load → inject    │    │  (OpenAI 兼容)  │
        │ memory → call    │    │  stream + JSON  │
        │ → parse → save   │    └────────┬────────┘
        └─┬───┬────────────┘             │
          │   │                          │
   ┌──────▼─┐ │ ┌───────────┐    ┌──────▼─────┐
   │Skill   │ │ │ Memory    │    │ HTTP / dio │
   │Loader  │ │ │ Inject +  │    └────────────┘
   │(assets)│ │ │ Extractor │
   └────────┘ │ └─────┬─────┘
              │       │
        ┌─────▼───────▼──────┐
        │ Drift (SQLite)     │
        │ + 本地文件         │
        └────────────────────┘
```

## 3. 里程碑总览

| 里程碑 | 主题 | 状态 |
|---|---|---|
| **M1** | 项目骨架 + LLM 配置 + 基础 UI 风格 | ✅ 已完成 |
| **M2** | Skill 引擎 + 通用聊天 + 记忆系统 | 🚧 进行中 |
| **M3** | 拍照识别能不能吃 | ✅ 已交付（提前于 M2） |
| **M4** | 孕期周历 + 周提醒 | ⏳ 待开始 |
| **M5** | 肚肚照时间线 | ⏳ 待开始 |
| **M6** | Checklist 库（产前 / 采购） | ⏳ 待开始 |
| **M7** | 打磨 / 备份 / 自定义 skill 导入 | ⏳ 待开始 |

> 提前完成的部分：CLI 测试器 (`tool/skill_test.dart`)、家庭画像 + onboarding（用户提前要求）。

## 4. M2 详细计划

### 4.1 目标

把 App 从「只有一个食物识别按钮 + 6 个静态视觉 mock」升级成「主入口是聊天 + 自带家庭记忆 + 所有 skill 都跑通用引擎」。

### 4.2 已经做掉的（提前做了）

- ✅ `SkillParser` / `SkillLoader`（assets 内置）
- ✅ `LlmClient`（OpenAI 兼容协议，含流式 + 非流式 JSON 调用）
- ✅ `FamilyProfile` + 引导页（不在原计划，用户要求）
- ✅ `FoodSafetyRunner`（M3 提前做了）
- ✅ 本地 CLI skill 测试器

### 4.3 M2 待办（按依赖顺序）

#### Step A · 通用 SkillRunner

替换掉 `FoodSafetyRunner` 里的特例代码，所有 skill 走同一套引擎。

- 新文件 `lib/core/skill/skill_runner.dart`
- 新文件 `lib/core/skill/skill_output.dart` — `SkillRunResult`（rawText / structuredJson / checklistSections）
- 入参：skill name + text + image + profile + 流式回调（可选）
- 内部：load skill → 注入 memory → 拼 messages → 调 LLM → 按 outputFormat 解析 → 写 `skill_runs`
- Provider：`skillRunnerProvider`
- `FoodSafetyRunner` 退化成 `SkillRunner.run('food-safety', ...)` + 把结构化输出映射成 `FoodSafetyResult`

#### Step B · 通用聊天 ChatPage

- 新文件 `lib/features/chat/chat_page.dart` + `chat_session_controller.dart`
- 流式渲染（基于 `LlmClient.chat()` 的 SSE）
- 输入支持文字 + 附图（图片小气泡显示）
- 写库 `chat_sessions` + `messages`
- Skill 默认 `chat`；后续可在顶部切其它纯文字 skill（食谱 / 周建议 / ...）
- 首页底部「聊聊」横条 onTap 进入

#### Step C · Memory CRUD + 管理 UI

- 新文件 `lib/core/memory/memory.dart` — `MemoryEntry { id, type, name, description, body, status, createdAt, updatedAt }`
- 新文件 `lib/core/memory/memory_repository.dart` — drift 上的 CRUD（已有 `memories` 表）
- 新文件 `lib/features/memory/memory_list_page.dart` — 4 个 tab（user / feedback / project / reference），+ 候选抽屉
- 设置页 → 「记忆管理」可点

#### Step D · Memory Injector，集成进 SkillRunner

- 新文件 `lib/core/memory/memory_injector.dart`
- 读取 skill frontmatter 的 `context.memory_keys` 与 `context.memory_topk`
- 精确匹配 + LIKE 模糊匹配，按 `updatedAt desc` 取 top-K
- 拼成 markdown bullet 段，加入 system prompt 的「## 记忆」段
- SkillRunner 调用 LLM 前自动调用 injector

#### Step E · Memory Extractor + 候选抽屉

- 新文件 `lib/core/memory/memory_extractor.dart`
- 每轮 chat assistant 响应结束后，用 cheap 文字模型跑一次「家庭事实抽取」
- 候选写库 `status='pending'`
- ChatPage 顶部 / 设置页有红点入口
- 候选抽屉点「收藏」转 `active`，点「拒绝」删除

#### Step F · Skill 列表页

- 新文件 `lib/features/skills/skill_list_page.dart`
- 列出 7 个内置 skill，显示：title / description / 是否视觉 / temperature / 来源（assets）
- 后续 M7 加用户导入

### 4.4 完成 M2 后的体验

- 聊天里说「老婆 8 月 15 号预产期」→ 候选抽屉冒一条 → 一键收纳 → 之后所有 skill 自动带这条上下文
- 食物识别命中过敏原（记忆里）会直接判 avoid
- 食谱推荐自动避过敏 + 命中孕期所需营养
- 「聊聊」入口能把日常零碎对话沉淀成长期家庭画像

### 4.5 不在 M2 里的事（往后排）

- 食谱 / 周建议 / 肚肚照 / Checklist 的真实数据接入 → M3 / M4 / M5 / M6
- 用户从手机文件系统分享 .md 进 App → M7
- Memory 的语义化检索（向量 / FTS5） → M2 收尾后再考虑
- 本地通知调度 → M4
- 多账户 / 云同步 → 不做（隐私优先）

## 5. M3-M7 概要

### M3 拍照识别（已交付主体）

剩下：换上 mimo-v2.5 等真视觉模型后做一次端到端验证。

### M4 孕期周历 + 周提醒

- `pregnancy-week` skill 接入真孕周
- 横向轮播「这一周宝宝」卡片
- `flutter_local_notifications` 注册每周一/四 9:00 提醒
- 启动时预生成下一周缓存，避免点开通知再等 LLM

### M5 肚肚照时间线

- 拍照 → 自动算孕周 → 落到 `belly_photos` 表
- 8 月份 grid 展示
- 拼图导出（screenshot 模块）
- 可选：让 `belly-photo` skill 给一段记录文字

### M6 Checklist 库

- 解析 `prenatal-prep` / `baby-shopping` 的 markdown 列表 → `checklist_templates`
- 实例化为可勾选清单，落 `checklist_instances` + `checklist_items`
- 「让 AI 补充」按钮：调 skill 增量返回追加项

### M7 打磨与发布

- iOS 文件分享导入 .md → SkillLoader merge 入口
- 黄金路径 e2e (patrol / integration_test)
- 数据导出 / 导入 .zip（含 skill_runs、memories、photos，但不含 LLM key）
- icon / 启动屏 / App Store / Play Store 物料

## 6. 文件 / 模块对应表（供查询）

| 关注点 | 文件 |
|---|---|
| Skill 解析 | `lib/core/skill/skill.dart`, `skill_parser.dart`, `skill_loader.dart` |
| Skill 执行（M2 新） | `lib/core/skill/skill_runner.dart`, `skill_output.dart` |
| LLM 抽象 | `lib/core/llm/llm_client.dart`, `openai_compatible_client.dart`, `types.dart` |
| LLM 配置 | `lib/core/config/llm_config.dart`, `secure_storage.dart` |
| 家庭画像 | `lib/core/profile/profile.dart`, `profile_repository.dart` |
| 记忆（M2 新） | `lib/core/memory/memory.dart`, `memory_repository.dart`, `memory_injector.dart`, `memory_extractor.dart` |
| 数据库 | `lib/core/storage/database.dart`, `tables.dart`, `file_store.dart` |
| 通用 UI | `lib/ui/theme.dart`, `widgets/cream_widgets.dart` |
| 入口 | `lib/main.dart`, `router.dart` |
| 首页 / 引导 / 设置 | `lib/features/home/`, `onboarding/`, `settings/` |
| Skill 屏 | `lib/features/{food_safety,pregnancy,pregnancy_recipe,belly_photo,checklist,baby_shopping}/` |
| 聊天（M2 新） | `lib/features/chat/` |
| 记忆管理（M2 新） | `lib/features/memory/` |
| Skill 列表（M2 新） | `lib/features/skills/` |
| Skill 内容 | `assets/skills/<name>/SKILL.md` ×7 |
| 本地工具 | `tool/skill_test.dart` + `docs/skill-test.md` |
