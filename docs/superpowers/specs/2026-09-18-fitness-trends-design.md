# 体重记录 + 健身趋势页 · 设计文档

> 日期：2026-09-18 · 分支：`feat/weight-log-trends`
> 前置：`2026-06-16-fitness-kettlebell-design.md`（该文档 §1「范围外」把历史趋势推到了后续，本文承接）

---

## 1. 目标与排序

爸爸想看数据随时间的变化：**体重曲线 · 每日热量摄入 vs 目标 · 训练坚持度**。

热量与训练的历史数据已经在 `meal_log` / `training_log` / `daily_plan` 里按日期躺着，
只缺范围查询和图。**体重是唯一在主动丢失的数据**：`fitness_profile` 是单行表，
`saveProfile` 用 `insertOnConflictUpdate`，每次改体重直接覆盖旧值，不留记录。

减脂目标下最该看的就是体重曲线，而它恰恰是唯一没留历史的。因此分两步：

| 步骤 | 内容 | 理由 |
|---|---|---|
| **P0（本轮）** | `weight_log` 表 + 今日页快速称重入口 | 每拖一天就多丢一天数据；改动小、独立可用 |
| **P1（攒数据后）** | 趋势页三张卡 | 现在做出来体重只有一个点，图上没东西可看 |

### 范围外
- 周报 / AI 总结
- 数据导出
- 与孕期妈妈饮食运动数据联动

---

## 2. P0 · 数据模型

新增 `weight_log`，schema **v6 → v7**：

| 字段 | 类型 | 说明 |
|---|---|---|
| id | int auto | |
| date | text | yyyy-MM-dd，**唯一** |
| weightKg | real | |
| createdAt | datetime | |

**一天一条，重复称重替换旧值**（`uniqueKeys = [{date}]` + upsert）。与既有的
「三餐重拍替换而非累加」（commit `dc621bd`）保持一致，避免同日多条把曲线画成锯齿。

### Repository

```
Future<void> saveWeight({required String date, required double weightKg})
Future<WeightEntry?> latestWeight()
Future<WeightEntry?> weightOn(String date)
Future<List<WeightEntry>> weightsBetween(String from, String to)   // P1 用
```

`saveWeight` **必须同时回写 `fitness_profile.weightKg`** —— 否则 BMR（`FitnessCalc.bmr`）
与 MET 消耗（`FitnessMet.netKcal`）仍在用旧体重算，今日消耗卡会与体重卡对不上。

---

## 3. P0 · 采集入口

今日页**最上方**一张窄 `CreamCard`（在「今日训练」之上）：

- 今天没称：`⚖️ 今天称了吗` + `CreamButton`「记一下」
- 今天称过：收起成一行 `⚖️ 92.3 kg · 比上次 −0.4 kg`

差值用语义色：减脂目标下变轻走 mint500，变重走 lemon500；增肌目标反过来。

### 称重弹窗

复用 `activity_sheet.dart` 的底部弹窗形态：数字输入 + `±0.1 / ±0.5` 步进按钮，
默认值 = 上次体重（没有则 profile 里的体重）。

### 两道校验

1. **范围**：沿用 `FitnessCalc.minWeightKg / maxWeightKg`（30–300kg），一套标准不重复定义
2. **跳变**：与上次相差 > 5kg 时二次确认「确定是 82 kg 吗，比上次少了 10 kg」

第二道是 `age=402` 事件的教训：单点范围校验拦不住「92 打成 9.2」这类错，跳变检测能。
阈值 5kg 定在 `FitnessCalc.maxDailyWeightSwingKg`。

---

## 4. P1 · 范围查询与纯函数

Repository 补 4 个范围查询：`weightsBetween` / `mealsBetween` / `trainingBetween` / `plansBetween`。

新建 `lib/features/fitness/fitness_trends.dart`，**全部纯函数、无框架依赖**，
与 `FitnessMet` / `FitnessCalc` 的分工一致——图表 widget 只负责画，不负责算：

| 函数 | 产出 |
|---|---|
| `dailyIntake()` | 按日聚合的热量与宏量 |
| `weightSummary()` | 起始 / 当前 / 净变化 / 平均每周变化 |
| `intakeVsTarget()` | 每日超欠 + 达标天数 |
| `trainingStreak()` | 当前连续天数 / 最长连续 / 本月次数 |

---

## 5. P1 · 趋势页

路由 `/fitness/trends`，入口在今日页 AppBar（现有 `tune` 图标旁加图表图标）。

顶部时间跨度 `CreamPill`：`7 天 / 30 天 / 90 天`，**默认 30 天**（减脂周期的合适尺度）。

| 卡 | 画法 | 配色 |
|---|---|---|
| 体重 | `LineChartPainter` 折线 + 目标带 | 线 peach500，目标带 cream300 |
| 热量 vs 目标 | `BarChartPainter` 柱状 + 目标横线 | 达标/欠 mint500，超标 lemon500 |
| 训练坚持度 | 圆角方块 `Wrap`，无需 painter | 练了 mint500，没练 cream200 |

超标用 lemon（提醒）而非 rose（警示）：按设计系统 §2 的语义，多吃两百大卡不是错误。

### 图表实现：`CustomPainter` 手绘，不引第三方库

`MacroRing` 已经证明这条路在本项目走得通（`_RingPainter` 连 2px 描边都是
`drawCircle(radius + 5)` 手绘的）。`fl_chart` 的默认视觉是 Material 细线 + 渐变，
与「胖胖描边 + 落地阴影」不是一个语言，改到不违和的代价未必小于手绘，还多背一个依赖。
遵循 CLAUDE.md §10.5「风格一致性 > 局部最优」。

**只新增 2 个 painter**，热力图用普通 widget 拼。

### 空状态

数据少于 3 天时不画图，显示 cream200 空状态 +「再记几天，我就能画出曲线了」。
体重从零开始，这个状态会持续一到两周，必须做得好看。

---

## 6. 测试策略

- `fitness_trends.dart` 四个纯函数：正常 / 空数据 / 单点 / 跨月边界（单元测试）
- 体重跳变校验：纯函数，单元测试
- `weight_log` CRUD：同日 upsert 替换、范围查询边界（in-memory db）
- `saveWeight` 回写 profile：存完读 profile 确认体重已更新
- 称重卡与趋势卡：widget 测试（渲染 + 空状态 + 无溢出）
- 新写的 widget 测试要做变异验证——上一轮 `onLongPress` 被 `onTap` 顶掉的 bug
  就是靠变异测试才发现的

---

## 附：按日历史明细（2026-09-21 追加）

P1 拆成两步交付：

| 步 | 内容 | 理由 |
|---|---|---|
| **P1a** | 范围查询 + 按日列表 + 某日明细 | 「分析问题」靠翻某天的明细，不靠曲线；不依赖画图 |
| **P1b** | 三张趋势图（见 §5） | 工作量集中在 CustomPainter，与明细不耦合 |

### 页面

`/fitness/history`，入口在今日页 AppBar（`tune` 图标旁）。
顶部时间跨度 `CreamPill`（7/30/90 天，默认 30），下面按日列表：

```
9月21日 周日    🍽 1840 大卡   🏋️ 已完成   ⚖️ 94.1kg
9月20日 周六    🍽 2310 大卡   🏋️ —
```

**只列出有任何记录的日子**，完全空白的日子跳过——90 天里大半是空行只会淹没信息，
日期出现断档本身就说明那几天没记。单日内某项没记则如实留空，不补零：
「那天没记」和「那天吃了 0 卡」是两回事。

### 某日明细

点开某天 → 三餐（食物清单 + 热量 + 当时的照片）、训练（计划 + 完成与否）、
日常活动、体重。

照片文件可能已被系统清理，**文件不存在时退化成只显示食物清单**，不显示破图。

**点某一餐直接进 `MealCapturePage(date: 那天, meal: 那餐)`**——#10 做的编辑能力
在这里自动生效，翻到三天前发现记错了当场能改。这是把 ① 排在 ② 之前的原因。

### 数据层

repository 补 `mealsBetween` / `trainingBetween` / `plansBetween`
（`weightsBetween` 已有）。新建 `lib/features/fitness/fitness_trends.dart`
放按日聚合的纯函数，P1b 的图表直接复用。

### 偏离原设计：趋势卡并入历史页（2026-09-21）

§5 原本规划独立的 `/fitness/trends` 页。P1a 落地后 `/fitness/history` 已经带了
跨度切换和按日列表，再开一个页会变成两个「看历史」的入口，还得各自维护一套
跨度状态。

**三张趋势卡改为放在历史页的列表上方**：跨度切换 → 趋势卡 → 按日列表，一条动线。
不再新增 `/fitness/trends` 路由。

其余规格（画法、配色、最少 3 天才画图）照 §5 执行。
