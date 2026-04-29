# good-dad · 项目设计语言

> 这是 good-dad（准爸爸孕期助手 app）的设计语言规范。任何 UI / 视觉 / 交互改动都要先看这份文件，再动手。
> 风格关键词：**圆润奶油 · 温柔不卖萌 · 爸爸用着不尴尬**。

---

## 1. 设计系统总览

| 维度 | 选择 | 理由 |
|---|---|---|
| 风格定位 | 圆润奶油 + Duolingo 式胖胖描边 | 可爱但不娘，妈妈觉得贴心，爸爸用着不尴尬 |
| 配色基调 | Cream（米色底）+ Peach（主品牌色） | 比纯白柔和，眼睛舒服；不用粉色，避免"娘化" |
| 描边 | 2px ink.900 实线 | Neobrutalism 派生，让卡片"立得住" |
| 阴影 | 0 3px 0 0 ink.900（不模糊、不偏移） | 落地感强，胖胖的玩具感 |
| 圆角 | 18 / 24 / 32（默认 24） | 大圆角 = 安全感 |
| 字体 | Nunito（拉丁/数字）+ HarmonyOS Sans（中文） | Nunito 圆润但不卡通；中文走系统圆体 |
| 插画 | emoji 当贴纸（彩色圆盘 + 描边 + 微旋转） | 最快、跨平台一致、便于扩展 |

完整规范见 `docs/design-system.md`。视觉参考见 `good-dad-cute.html`。

---

## 2. 色板（直接对应 `lib/ui/theme.dart` 的 `AppColors`）

### Cream（中性底）
- `cream50` `#FFFBF5` — 全局底色
- `cream100` `#FFF4E6` — 卡片底
- `cream200` `#FCEBD3` — 二级面板 / 空状态
- `cream300` `#F8DDB8` — 分隔块

### Peach（主品牌色）
- `peach200` `#FFD9C7` — 高亮底
- `peach300` `#FFC9B5` — 强调底
- `peach500` `#FF8F6B` — 主 CTA / 选中态
- `peach700` `#D9684A` — 按钮按下 / 文字强调

### Functional
- `mint500` `#7FC8A9` — 成功 / 已完成 / 安全食物
- `sky500` `#8FB8DE` — 信息 / 睡眠数据
- `lemon500` `#F5C95A` — 提醒 / 待办高亮
- `rose500` `#E07A8B` — 警示 / 不能吃 / 异常

### Ink（深焦糖代替纯黑）
- `ink900` `#3D2E22` — 主文字 / 描边
- `ink600` `#7A6A5A` — 次要文字
- `ink400` `#B5A89A` — 占位 / 禁用

### Dark mode
深色基底 `#1F1A14`；cream 色相整体降亮 70%，强调色保持。

---

## 3. 间距 / 圆角 / 阴影 token

```dart
AppSpacing.xs/sm/md/lg/xl/xxl  = 4 / 8 / 12 / 16 / 24 / 32
AppRadius.sm/md/lg/xl/pill     = 12 / 18 / 24 / 32 / 999
AppShadows.pop(isDark)         // 0 3px 0 ink900 — 唯一的标准阴影
```

**默认卡片** = 2px 描边 + 24 圆角 + pop 阴影 + 16 内边距。

---

## 4. 字体

- **拉丁/数字**：Nunito（在 `pubspec.yaml` 注册），weights: 600/700/800/900
- **中文 fallback**：HarmonyOS Sans / 思源黑体 / 阿里妈妈方圆体（系统选）
- 数字记得用 tabular-nums（`fontFeatures: [FontFeature.tabularFigures()]`）
- 最小字号 12sp；正文 ≥ 14sp；爸爸常在通勤、夜里看，可读性优先

字号体系：
- display 32 / titleLarge 22 / titleMedium 18 / bodyLarge 16 / bodyMedium 14 / labelLarge 13 / labelSmall 11

---

## 5. 核心 widget（`lib/ui/widgets/cream_widgets.dart`）

| Widget | 用途 |
|---|---|
| `CreamCard` | 默认卡片，2px 描边 + 落地阴影 |
| `Sticker` | emoji 贴纸（彩色圆盘 + 描边 + 微旋转） |
| `CreamPill` | chip / 标签 |
| `CreamButton` | 主 CTA / Ghost 按钮（带 emoji） |
| `SkillCard` | 首页 skill 入口卡 |
| `StatusTag` | `SafetyTag.ok / avoid / caution / info` 四色标 |

**所有按钮高度 ≥ 56dp**（爸爸单手操作）。

---

## 6. emoji 用法规范

emoji 不是表情，是**贴纸**：
- 永远套在 `Sticker` 里（圆盘 + 描边 + 阴影），不直接裸露在文字流
- 颜色按语义选 bg：可吃 mint / 不能吃 rose / 提醒 lemon / 信息 sky
- 微旋转 -6° / +6° 给"手绘感"，但只用在装饰性 sticker 上，状态/按钮里不旋转
- **禁止**：emoji 堆叠（一行 3 个以上）、用 emoji 当功能图标按钮

icon 仍走 Material Icons outlined / rounded 系列；emoji 只用于**情绪 / 内容**节点。

---

## 7. 文案 Voice & Tone

- 称呼：默认「爸爸」「妈妈」（设置可改），不写「用户」
- AI 用第一人称：「我帮你看了下…」
- 一段最多 1 个感叹号
- 时间用相对：「2 小时前喂的」
- 数据带对比：「比昨天多睡 20 分钟」
- 医学话题保守：「这个我不太敢替医生说，建议你问下产检医生」

文案对照表见 `docs/design-system.md` § 7。

---

## 8. 动效

- 过渡 200ms，curve 用 `Curves.easeOutQuart`
- 卡片进入：从下 8px 上滑 + 透明度 0→1
- 完成动作：贴纸 scale 0.8→1.05→1（250ms）
- 按钮按下：translateY(2px) + 阴影变 0 1px 0（"按到地上"）

---

## 9. 落地优先级

| Phase | 内容 | 状态 |
|---|---|---|
| P0 | 主题 ThemeData / CreamCard / 首页骨架 | 设计稿就绪，待落 Flutter |
| P1 | 7 个 Skill 屏（能不能吃 / 食谱 / 孕周 / 肚肚照 / 待产包 / 采购 / 聊聊） | 设计稿就绪 |
| P2 | 提醒中心 / 贴纸完成动效 / 深色模式 | 待设计 |
| P3 | 平板适配 / 无障碍 / 动效完善 | 待设计 |

---

## 10. 修改纪律

1. **新组件先问"已有 widget 能不能复用"** — `CreamCard` + `Sticker` + `CreamPill` 能覆盖 80% 场景
2. **新颜色必须先进 `AppColors`** — 不要在 widget 里写裸色值
3. **改 token 同步更新 `docs/design-system.md`** — 文档和代码不能漂移
4. **HTML 设计稿是真相源** — `good-dad-cute.html` 是视觉对照标准；Flutter 实现要跟它一致
5. **风格一致性** > 局部最优 — 宁可少做一个屏幕，不要在一个屏里破坏系统

---

## 11. 文件位置速查

```
lib/ui/theme.dart                       # AppColors / AppRadius / AppSpacing / AppShadows / AppTheme
lib/ui/widgets/cream_widgets.dart       # CreamCard / Sticker / CreamPill / CreamButton / SkillCard / StatusTag
lib/features/<skill>/...                # 各 skill 屏幕
docs/design-system.md                   # 完整设计系统文档（中文）
good-dad-cute.html                      # 视觉对照设计稿（HTML 版）
flutter-integration/                    # HTML → Flutter 翻译参考代码
```
