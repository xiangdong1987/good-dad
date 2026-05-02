# 商店上架资料

把下面内容直接粘到 Play Console / App Store Connect。

---

## App 名 / Title

- 中文：good-dad · 准爸爸 AI 助手
- English: good-dad · AI assistant for new dads

> Apple Title 上限 30 字符，副标题 30 字符；Play 标题上限 30 字符。

## 简短描述 (Play 80 字 / Apple Subtitle 30)

- 中文：陪准爸爸把孕期 / 育儿 / 家庭日程，一件件做好。
- English: AI sidekick for expecting and new dads.

## 完整描述

### 中文版

```
good-dad 是给准爸爸 / 新手爸爸的 AI 伴侣。它做四件事：

1. 食物能不能吃 — 拍一张，AI 给孕期友好度判断 + 替代建议
2. 孕期周历 — 每周自动生成宝宝发育要点 / 妈妈这周注意 / 爸爸能帮的事
3. 待产包 / 宝宝采购清单 — AI 列、你勾，再让 AI 补漏
4. 私人对话 + 记忆 — 它会记住老婆的预产期、过敏、口味等长期事实，下次自动用上；你提一句「下周三 9 点产检」会自动加到日历

特点：
· 100% 本地存储，所有聊天 / 照片 / 记忆都在你的手机里
· 无后端、无广告、无追踪
· 自带 LLM API key — 选 OpenAI、Claude、通义千问、Mimo Token Plan 都行
· 支持中 / 英 / 日 / 繁体语言切换

注意：本应用的孕期 / 育儿 / 食品建议仅供参考，不构成医疗建议；具体健康问题请咨询医生 / 营养师。
```

### English

```
good-dad is an AI sidekick for expecting and new dads. It does four things:

1. Can-I-eat-this — snap a photo, get pregnancy-friendly verdict + alternatives
2. Weekly pregnancy briefs — what baby's doing, what mom needs, what dad can do
3. Hospital bag & baby shopping — AI lists, you tick, AI fills gaps
4. Personal chat with memory — it remembers due date, allergies, preferences for next time. Say "OB visit Wed 9am" and it lands on the calendar automatically.

Highlights:
· 100% local storage — chats / photos / memories all stay on your phone
· No backend, no ads, no tracking
· Bring your own LLM API key — OpenAI, Claude, Tongyi, MiMo all work
· Chinese, English, Japanese, traditional Chinese

Disclaimer: pregnancy / childcare / food guidance is for reference only and not medical advice. Consult a licensed professional for health decisions.
```

## 关键词 (Apple, 100 字符以内, 逗号分隔)

```
pregnancy,baby,dad,checklist,reminder,nutrition,AI,parenting,journal,due date
```

中文版（部分商店允许）:
```
孕期,准爸爸,产检,待产包,食谱,孕妇,宝宝,记忆,清单,本地AI
```

## 分类

- 主分类：**Health & Fitness** 或 **Lifestyle**（避开 Medical，避开严格审核）
- Apple 副分类：Lifestyle / Productivity

## 内容分级

- ESRB / IARC：4+ / Everyone
- 不含暴力、恐怖、博彩、加密资产、UGC 公共展示等敏感内容

---

## Google Play 数据安全表 (Data safety form)

直接照下面填：

### Does your app collect or share any of the required user data types?
**No**

> 解释（你只在内部留底，不需要交）：所有数据存储在用户设备本地。AI 调用直接打到用户配置的第三方 LLM 服务，不经我们任何后端。

### Is all of the user data collected by your app encrypted in transit?
N/A —— App 本身不收集数据上行。但实际你写：
**Yes** — All data is encrypted in transit. (因为你和 LLM 走 HTTPS)

### Do you provide a way for users to request that their data is deleted?
**Yes** — Users can clear all local data by uninstalling the app or deleting individual records in-app.

### Has your data collection and handling practices been independently validated against a global security standard?
**No**

---

## Apple Privacy Nutrition Label

App Store Connect → "App Privacy" → Add data type collected:

**Data Not Collected** —— 选这个。

如果系统逼你勾"Used to Track You"等：选 **Not collecting any data**。

---

## 截图清单（你需要拍的）

5-8 张，按这个顺序：

1. **首页** — TodayCard + skill grid（要有真实风格的孕周徽章 + 几条 todo）
2. **食物识别结果卡** — 一道家常菜返回 caution + 替代 + dos/donts
3. **孕期周历** — 大数字 + 6 张卡的展开
4. **聊聊** — 一段对话 + AI 已加日历的 system 气泡
5. **日历页** — 月视图 + 当前周徽 + 几个事件点
6. **待产包 / 采购** — 进度条 + 分组 checklist
7. **设置页** — 顶部能看到 LLM 配置区域 + 「家庭信息」「日历」「语言」入口

### 尺寸要求

- **iOS 6.7"**: 1290 × 2796（iPhone 16/15 Pro Max）
- **iOS 6.5"**: 1242 × 2688（备用）
- **iOS 5.5"**: 1242 × 2208（已强制）
- **iPad 12.9"**: 2048 × 2732（如果你支持 iPad）
- **Android Phone**: 1080 × 1920 起步，9:16 或 16:9
- **Feature Graphic** (Play): 1024 × 500，必填

技巧：用 iPhone 真机或 Simulator 跑 release 截图。可加文案条 (Figma / shottr)，但 Apple 不允许「过度装饰」(必须看出是 App)。

---

## 隐私政策 + 服务条款 URL

把 `docs/privacy-policy.md` + `docs/terms-of-service.md` 内容部署到一个公网 URL，例：

- GitHub Pages: `https://<你的-github-用户名>.github.io/good-dad/privacy/`
- 或自建：`https://your-domain.dev/privacy`

填到：
- Play Console: 「Store presence → Main store listing → Privacy policy URL」
- App Store Connect: 「App Information → Privacy Policy URL」+ 「Terms of Use URL」

---

## 上架前最后 checklist

- [ ] 包名 `com.siyou.good_dad` —— 想换的话**现在**改，上架后不能改
- [ ] App icon / splash screen 看起来不像默认
- [ ] `pubspec.yaml` 的 `version` 设好（`1.0.0+1` 起步）
- [ ] 内置 SKILL.md 已脱敏（已加 "示例不是真实数据" 备注）
- [ ] 有真实可访问的隐私政策 URL
- [ ] release 签名 keystore 已生成 + 备份（`docs/release-signing.md`）
- [ ] `flutter analyze` 0 issue
- [ ] `flutter test` 全绿
- [ ] 真机 `--release` 跑通主要功能
- [ ] 截图 5-8 张
- [ ] 中英描述准备好
- [ ] 内容分级问卷做完
- [ ] 数据安全表填完
