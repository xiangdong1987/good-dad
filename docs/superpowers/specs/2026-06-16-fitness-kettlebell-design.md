# 壶铃训练 + 三餐拍照分析模块 · 设计文档

> 日期：2026-06-16 · 分支：`feat/fitness-kettlebell`
> 定位：good-dad（准爸爸孕期助手）中**给爸爸自己**的健康管理模块，与孕期主题平行共存。
> 形态：复用现有 skill 系统，在首页挂一张壶铃 `SkillCard`；内部是带 drift 数据层的完整 feature。

---

## 1. 目标与范围

爸爸在老婆孕期也要保持状态：每天用壶铃训练、记三餐、晚上拿到「明日训练 + 饮食计划」。

核心闭环（每日循环）：

```
白天：拍照记三餐 → AI 估热量/宏量 → 累计今日缺口
      做今日训练 → 标记完成
晚上：固定时间静态提醒「明日计划准备好啦」
      用户点开 → 现场用今日数据调 LLM → 生成并缓存明日计划
次日：今日页展示训练计划 + 三餐目标，循环继续
```

**安全（"安全壶铃训练"）= 把伤病/禁忌动作 + 新手降负荷规则作为硬约束喂给 LLM，并在页面固定保守免责文案。**

### 范围内（MVP）
- fitness_profile 引导填写 + 编辑
- 拍照记三餐（AI 分析 + 用户可改）
- 今日训练计划展示 + 标记完成
- 每晚静态提醒 + App 内现场生成明日计划（闭环：参考今日实际饮食/训练）
- 今日页热量/宏量进度环 vs 目标

### 范围外（后续）
- 训练动作视频/动图库
- 历史趋势图表、周报
- 后台任务静默生成（iOS BGTask 不保证准时，先不做）
- 与孕期妈妈饮食/运动联动

---

## 2. 架构决策

**完整 feature（带 drift 数据层），prompt 内联在 feature，不走 SKILL.md。**

理由：模块需长期持久化身体数据、壶铃配置、每日三餐、训练历史、缓存的明日计划——纯 SKILL.md prompt 装不下。拍照分析与计划生成都需要**严格 JSON 输出**给本地解析与缺口对比，prompt 内联比 skill_runner 的纯文本输出更可控。

复用：
- LLM：现有 `lib/core/llm/LlmClient`（`chatOnce`，`needsVision: true` 走 vision）。
- 通知：仿 `lib/core/notification/weekly_notifier.dart` 写一个 `DailyPlanNotifier`。
- 存储：现有 drift database（`lib/core/storage`）。
- UI：严格走 `lib/ui/theme.dart` + `lib/ui/widgets/cream_widgets.dart` 设计系统。
- 首页入口：复用 `SkillCard`，视觉与现有 7 个 skill 一致。

---

## 3. 数据模型（drift，4 张表）

### `fitness_profile`（单行）
| 字段 | 类型 | 说明 |
|---|---|---|
| id | int (固定=1) | 单行 |
| heightCm | int | 身高 |
| weightKg | real | 体重 |
| age | int | 年龄 |
| sex | text | male/female |
| kettlebellsKg | text(JSON) | 手边壶铃重量列表，如 `[8,12,16]` |
| experience | text | novice/intermediate |
| dailyMinutes | int | 每日可用训练分钟数 |
| goal | text | cut/gain/maintain（减脂/增肌/保持） |
| injuries | text | 伤病/禁忌动作自由文本 |
| updatedAt | datetime | |

### `meal_log`
| 字段 | 类型 | 说明 |
|---|---|---|
| id | int auto | |
| date | text(yyyy-MM-dd) | 归属日期 |
| meal | text | breakfast/lunch/dinner/snack |
| photoPath | text? | 本地照片路径 |
| foods | text(JSON) | AI 识别食物清单 |
| kcal | int | 热量 |
| proteinG / carbG / fatG | int | 三大营养素(g) |
| edited | bool | 用户是否手改过 |
| createdAt | datetime | |

### `training_log`
| 字段 | 类型 | 说明 |
|---|---|---|
| id | int auto | |
| date | text(yyyy-MM-dd) | |
| plan | text | 当日训练计划文本（来自 daily_plan） |
| done | bool | 是否完成 |
| feeling | text? | 练后感觉（可选） |

### `daily_plan`（缓存，推送提醒与页面共用）
| 字段 | 类型 | 说明 |
|---|---|---|
| targetDate | text(yyyy-MM-dd) | 计划针对的日期（主键） |
| trainingPlan | text(JSON/markdown) | 明日壶铃训练计划 |
| dietGuidance | text | 明日饮食建议 |
| kcalTarget | int | 明日热量目标 |
| proteinTarget / carbTarget / fatTarget | int | 明日宏量目标 |
| deficitSummary | text | 今日缺口摘要（生成依据） |
| generatedAt | datetime | |

---

## 4. LLM 调用（两条，复用 `LlmClient`）

### 4.1 拍照分析 `analyzeMeal(photo, meal)`
- `needsVision: true`，输入照片 + 餐次提示。
- system prompt 要求**严格 JSON**：`{foods:[{name,grams}], kcal, proteinG, carbG, fatG, note}`。
- 解析失败兜底：提示用户手动填写。
- 结果落 `meal_log`，UI 上字段可手动微调（标记 `edited=true`）。

### 4.2 明日计划生成 `generateTomorrowPlan(profile, todayMeals, todayTraining)`（闭环灵魂）
- 输入：完整 fitness_profile + 今日三餐热量/宏量合计与缺口 + 今日训练完成情况。
- system prompt 硬约束：
  - 显式纳入 `injuries` 禁忌，禁止编排相关动作；
  - `experience=novice` 时降负荷、控制组数、强调动作质量；
  - 训练时长 ≤ `dailyMinutes`；只用 `kettlebellsKg` 里有的重量。
- 输出严格 JSON：`{trainingPlan:[{move,sets,reps,weightKg,note}], dietGuidance, kcalTarget, proteinTarget, carbTarget, fatTarget, deficitSummary}`。
- 落 `daily_plan`（targetDate = 次日）。

---

## 5. 通知与生成时机

- 新增 `lib/core/notification/daily_plan_notifier.dart`（仿 `WeeklyNotifier`）：
  - 每晚固定时间（默认 21:00，设置可改）发**静态**通知「💪 明日计划准备好啦，点开看看」。
  - payload 深链 `/fitness`。
- 真正的 LLM 生成在**用户点开模块时现场跑**：
  - 进入 `/fitness` 时，若 `daily_plan(targetDate=明日)` 不存在且当前已过当日某时间点，则用今日数据生成并缓存；
  - 已生成则直接展示，不重复调 LLM。

> 本地通知在调度时即固定文字，无法在触发那一刻现场调 LLM（iOS 尤甚），故采用「静态提醒 + App 内现场生成」。

---

## 6. UI 结构（严格走 cream 设计系统）

入口：首页新增壶铃 `SkillCard` → `/fitness`。

### 今日页 `/fitness`
1. **今日训练计划卡**（`CreamCard`）：来自 `daily_plan`，列动作/组数/次数/重量，含「✅ 标记完成」按钮 → 写 `training_log`。
2. **三餐卡 ×3**（早/午/晚）：每张 `CreamCard` 带 热量/宏量**进度环** vs 目标 + 「📷 拍照记这餐」`CreamButton`。
3. **明日计划卡**：晚上生成后展示训练 + 饮食建议 + 缺口摘要。
4. 底部固定保守免责文案。

### 设置页 `/fitness/profile`
- 首次进入引导填 fitness_profile；之后可改（身体数据 / 壶铃重量 / 经验 / 时间 / 目标 / 伤病）。

### 拍照流
- 相机（`image_picker`）→「AI 分析中」`Sticker` 动效 → 结果卡（食物清单 + 热量/宏量，**可编辑**）→ 保存。

### 新 widget
- **`MacroRing`**：唯一新增 widget。配色走语义色——热量 peach / 蛋白 mint / 碳水 sky / 脂肪 lemon。其余全复用 `CreamCard`/`Sticker`/`CreamPill`/`CreamButton`/`StatusTag`。

---

## 7. 安全与文案

- 训练 prompt 强制纳入伤病禁忌 + 新手降负荷（见 §4.2）。
- 页面底部固定保守免责：「这是 AI 给的训练参考，身体不舒服就停，必要时问专业教练/医生」（呼应 CLAUDE.md §7 医学保守）。
- 称呼「爸爸」；AI 第一人称（「我帮你看了下今天的三餐…」）；相对时间；数据带对比（「比昨天多摄入 200 大卡」）。
- 一段最多 1 个感叹号。

---

## 8. 文件落点

```
lib/core/storage/                         # 新增 4 张 drift 表定义
lib/core/notification/daily_plan_notifier.dart   # 每晚静态提醒
lib/features/fitness/
  fitness_page.dart                       # 今日页
  fitness_profile_page.dart               # 设置/引导
  meal_capture_page.dart                  # 拍照流
  fitness_llm.dart                        # 两条 prompt + JSON 解析
  fitness_controller.dart                 # riverpod 状态/编排
  widgets/macro_ring.dart                 # 新 widget
lib/features/home/...                     # 加壶铃 SkillCard 入口
go_router 路由表                          # 注册 /fitness 等
```

---

## 9. 测试策略

- `fitness_llm` 的 JSON 解析：正常 + 脏输出兜底（单元测试，mock LlmClient）。
- 缺口计算：今日三餐合计 vs 目标（纯函数，单元测试）。
- drift 表 CRUD：profile 单行 upsert、meal_log 按日期查询、daily_plan 缓存命中（in-memory db 测试）。
- 生成时机判定：「是否需要生成明日计划」的纯函数。
